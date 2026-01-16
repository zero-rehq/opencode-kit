#!/bin/bash

# generate-openapi.sh - Generate OpenAPI spec from code
# Usage: ./generate-openapi.sh [framework] [output-file]
# Output: OpenAPI 3.0 spec JSON

set -e

FRAMEWORK="${1:-express}"
OUTPUT_FILE="${2:-openapi.json}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "API Documentation Generator"
echo "=========================================="
echo "Framework: $FRAMEWORK"
echo "Output: $OUTPUT_FILE"
echo ""

case "$FRAMEWORK" in
    express)
        echo -e "${GREEN}✓${NC} Using Express parser"
        echo ""
        echo "Scanning for JSDoc @openapi annotations..."

        # Check if project uses swagger-jsdoc
        if [ ! -f "package.json" ]; then
            echo -e "${RED}ERROR:${NC} package.json not found"
            exit 1
        fi

        # Check for swagger-jsdoc
        if ! grep -q "swagger-jsdoc" package.json; then
            echo -e "${YELLOW}WARNING:${NC} swagger-jsdoc not found"
            echo "Install it: npm install --save-dev swagger-jsdoc"
            echo ""
        else
            echo -e "${GREEN}✓${NC} swagger-jsdoc found"
        fi

        # Check for swagger-ui-express (for serving docs)
        if ! grep -q "swagger-ui-express" package.json; then
            echo -e "${YELLOW}WARNING:${NC} swagger-ui-express not found (optional for serving UI)"
            echo "Install it: npm install swagger-ui-express"
            echo ""
        fi

        cat << 'EOF'
==========================================
Next Steps for Express
==========================================

1. Add @openapi JSDoc annotations to your routes:

/**
 * @openapi
 * /api/users:
 *   get:
 *     summary: Get all users
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: List of users
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/User'
 */
app.get('/api/users', async (req, res) => {
  const users = await getUsers();
  res.json(users);
});

2. Create a script to generate OpenAPI spec (e.g., scripts/generate-openapi.js):

const swaggerJsdoc = require('swagger-jsdoc');
const fs = require('fs');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'My API',
      version: '1.0.0',
    },
  },
  apis: ['./src/routes/**/*.js', './src/controllers/**/*.js'],
};

const specs = swaggerJsdoc(options);
fs.writeFileSync('openapi.json', JSON.stringify(specs, null, 2));

3. Add to package.json scripts:
   "api-docs:generate": "node scripts/generate-openapi.js"
   "api-docs:serve": "swagger-ui-express"

4. Run: npm run api-docs:generate

EOF
        ;;

    nextjs)
        echo -e "${GREEN}✓${NC} Using Next.js parser"
        cat << 'EOF'
==========================================
Next.js API Routes
==========================================

For Next.js App Router API routes, use JSDoc:

// app/api/users/route.ts
/**
 * @openapi
 * /api/users:
 *   get:
 *     summary: Get all users
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: List of users
 */
export async function GET() {
  const users = await getUsers();
  return Response.json(users);
}

For Pages Router API routes:

// pages/api/users/index.ts
/**
 * @openapi
 * /api/users:
 *   get:
 *     summary: Get all users
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: List of users
 */
export default async function handler(req, res) {
  const users = await getUsers();
  res.json(users);
}

EOF
        ;;

    nestjs)
        echo -e "${GREEN}✓${NC} Using NestJS parser"
        cat << 'EOF'
==========================================
NestJS Decorators
==========================================

Use @nestjs/swagger decorators:

import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';

@ApiTags('Users')
@Controller('users')
export class UsersController {
  @Get()
  @ApiOperation({ summary: 'Get all users' })
  @ApiResponse({ status: 200, type: [UserDTO] })
  async findAll() {
    return this.usersService.findAll();
  }

  @Post()
  @ApiOperation({ summary: 'Create user' })
  @ApiResponse({ status: 201, type: UserDTO })
  async create(@Body() createUserDto: CreateUserDTO) {
    return this.usersService.create(createUserDto);
  }
}

Generate OpenAPI spec:
1. Add SwaggerModule to main.ts
2. Visit http://localhost:3000/api/docs
3. Export spec using SwaggerModule.getDocument()

EOF
        ;;

    *)
        echo -e "${RED}ERROR:${NC} Unsupported framework: $FRAMEWORK"
        echo "Supported frameworks: express, nextjs, nestjs"
        exit 1
        ;;
esac

echo "=========================================="
echo "Validation"
echo "=========================================="
echo ""
echo "After generating OpenAPI spec, run:"
echo "  ./validate-openapi.sh $OUTPUT_FILE"
echo ""
