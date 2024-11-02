#!/bin/bash
./build.sh
docker run -d -p 8000:8000 crawl4ai-fastapi
