set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Starting MCR Python Service...${NC}"

PACKAGE_NAME="mcr_py_email_builder_service"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo $SCRIPT_DIR
APP_FILE="${SCRIPT_DIR}/src/app.py"
echo $APP_FILE
if [ ! -f "$APP_FILE" ]; then
    echo -e "${RED}Error: app.py not found at ${APP_FILE}${NC}"
    exit 1
fi


export PYTHONPATH="${SCRIPT_DIR}:${SCRIPT_DIR}/src:${PYTHONPATH}"
unset PYTHONHOME

echo -e "${YELLOW}Package: ${PACKAGE_NAME}${NC}"

PACKAGE_NAME_HYPHEN=$(echo "$PACKAGE_NAME" | tr '_' '-')
if pip show "$PACKAGE_NAME_HYPHEN" 2>/dev/null | grep -q "Editable project location"; then
    echo -e "${GREEN}✓ Running in editable mode${NC}"
else
    echo -e "${YELLOW}⚠ Not in editable mode${NC}"
fi

echo -e "${GREEN}Starting application...${NC}\n"

cd "${SCRIPT_DIR}"
python "$APP_FILE"