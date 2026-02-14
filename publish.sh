#!/bin/bash
# ============================================================
# publish.sh — Build, verify, and push kvkart-db to Docker Hub
# ============================================================
# Usage:
#   ./publish.sh <your-dockerhub-username>
#
# Example:
#   ./publish.sh niranjan123
# ============================================================

set -e

DOCKERHUB_USER=${1:?"Usage: ./publish.sh <dockerhub-username>"}
IMAGE_NAME="$DOCKERHUB_USER/kvkart-db"
TAG="latest"

echo "============================================"
echo " KV Kart DB — Build & Publish"
echo " Image: $IMAGE_NAME:$TAG"
echo "============================================"
echo ""

# Step 1: Clean any previous state
echo "[1/6] Cleaning previous containers and volumes..."
docker compose down -v 2>/dev/null || true
echo "  Done."
echo ""

# Step 2: Build and start
echo "[2/6] Building image and initializing database..."
docker compose up -d --build
echo "  Waiting for MySQL to be healthy..."
until docker exec kvkart-db mysqladmin ping -h localhost -u root -pkvkart_root --silent 2>/dev/null; do
    sleep 2
    echo "  Still waiting..."
done
echo "  MySQL is ready."
echo ""

# Step 3: Verify data
echo "[3/6] Verifying database..."
RESULT=$(docker exec kvkart-db mysql -u diya -pdiya_password kvkart -N -e "
    SELECT
        (SELECT COUNT(*) FROM users) as users,
        (SELECT COUNT(*) FROM products) as products,
        (SELECT COUNT(*) FROM orders) as orders,
        (SELECT COUNT(*) FROM policies) as policies;
")
echo "  Row counts: users/products/orders/policies = $RESULT"

EXPECTED_USERS=15
ACTUAL_USERS=$(echo $RESULT | awk '{print $1}')
if [ "$ACTUAL_USERS" != "$EXPECTED_USERS" ]; then
    echo "  ERROR: Expected $EXPECTED_USERS users, got $ACTUAL_USERS"
    exit 1
fi
echo "  Verification passed."
echo ""

# Step 4: Stop the container (keep volume)
echo "[4/6] Stopping container..."
docker compose stop kvkart-db
echo "  Done."
echo ""

# Step 5: Commit the container with data baked in
echo "[5/6] Creating image snapshot with data..."
docker commit kvkart-db "$IMAGE_NAME:$TAG"
echo "  Image created: $IMAGE_NAME:$TAG"
echo ""

# Step 6: Push to Docker Hub
echo "[6/6] Pushing to Docker Hub..."
echo "  Make sure you are logged in: docker login"
docker push "$IMAGE_NAME:$TAG"
echo ""

echo "============================================"
echo " Published: $IMAGE_NAME:$TAG"
echo "============================================"
echo ""
echo " Teams can now run:"
echo ""
echo "   docker pull $IMAGE_NAME:$TAG"
echo "   docker run -d -p 3306:3306 --name kvkart-db $IMAGE_NAME:$TAG"
echo ""
echo " Or use docker-compose.team.yaml (update the image name first)"
echo "============================================"

# Cleanup
docker compose down -v 2>/dev/null || true
