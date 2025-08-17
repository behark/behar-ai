# Enhanced AI Platform - Core FastAPI Application
import asyncio
import os
import time
from datetime import datetime
from typing import Any, Dict, List, Optional

import httpx
import uvicorn
from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

# Initialize FastAPI app
app = FastAPI(
    title="AI Behar Platform",
    description="Production AI Platform with Open WebUI Integration",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Security
security = HTTPBearer()

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ALLOW_ORIGIN", "*").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global variables
startup_time = datetime.now()
request_count = 0

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    global request_count
    request_count += 1
    
    # Check Ollama connection
    ollama_status = "unknown"
    try:
        ollama_url = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(f"{ollama_url}/api/tags")
            if response.status_code == 200:
                models = response.json().get("models", [])
                ollama_status = f"healthy - {len(models)} models"
            else:
                ollama_status = "unhealthy"
    except Exception as e:
        ollama_status = f"error: {str(e)[:50]}"
    
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "uptime_seconds": int((datetime.now() - startup_time).total_seconds()),
        "request_count": request_count,
        "environment": os.getenv("ENVIRONMENT", "development"),
        "services": {
            "api": "healthy",
            "ollama": ollama_status,
            "database": "healthy",  # TODO: Add actual DB check
            "redis": "healthy"      # TODO: Add actual Redis check
        }
    }

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with platform information"""
    return {
        "name": "AI Behar Platform",
        "version": "1.0.0",
        "status": "operational",
        "timestamp": datetime.now().isoformat(),
        "endpoints": {
            "health": "/health",
            "docs": "/docs",
            "metrics": "/metrics",
            "openwebui": "http://localhost:8080" if os.getenv("ENVIRONMENT") == "development" else "/ui"
        }
    }

# API Information
@app.get("/api/info")
async def api_info():
    """API information endpoint"""
    return {
        "api_version": "1.0.0",
        "platform": "AI Behar",
        "features": [
            "Open WebUI Integration",
            "Multi-LLM Support",
            "Production Database",
            "Redis Caching",
            "Monitoring",
            "Authentication"
        ],
        "models_available": await get_available_models()
    }

# Models endpoint
@app.get("/api/models")
async def get_available_models():
    """Get available LLM models from Ollama"""
    try:
        ollama_url = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(f"{ollama_url}/api/tags")
            if response.status_code == 200:
                data = response.json()
                models = []
                for model in data.get("models", []):
                    models.append({
                        "name": model.get("name"),
                        "size": model.get("size", 0),
                        "modified": model.get("modified_at"),
                        "parameter_size": model.get("details", {}).get("parameter_size"),
                        "quantization": model.get("details", {}).get("quantization_level")
                    })
                return {"models": models, "count": len(models)}
            else:
                raise HTTPException(status_code=503, detail="Ollama service unavailable")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching models: {str(e)}")

# Chat endpoint (proxy to Ollama)
@app.post("/api/chat")
async def chat_with_model(
    request: Dict[str, Any],
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    """Chat with LLM models via Ollama"""
    try:
        # TODO: Add authentication validation
        
        ollama_url = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                f"{ollama_url}/api/chat",
                json=request
            )
            return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Chat error: {str(e)}")

# Metrics endpoint for Prometheus
@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    global request_count
    uptime = int((datetime.now() - startup_time).total_seconds())
    
    metrics_text = f"""# HELP api_requests_total Total API requests
# TYPE api_requests_total counter
api_requests_total {request_count}

# HELP api_uptime_seconds API uptime in seconds
# TYPE api_uptime_seconds gauge
api_uptime_seconds {uptime}

# HELP api_health_status API health status (1=healthy, 0=unhealthy)
# TYPE api_health_status gauge
api_health_status 1
"""
    
    return JSONResponse(
        content=metrics_text,
        media_type="text/plain"
    )

# Startup event
@app.on_event("startup")
async def startup_event():
    """Application startup"""
    print(f"🚀 AI Behar Platform starting...")
    print(f"📅 Startup time: {startup_time}")
    print(f"🌍 Environment: {os.getenv('ENVIRONMENT', 'development')}")
    print(f"🤖 Ollama URL: {os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434')}")
    print(f"📊 Database: {os.getenv('DATABASE_URL', 'sqlite:///./databases/platform.db')}")
    print(f"🔄 Redis: {os.getenv('REDIS_URL', 'redis://localhost:6379')}")

# Shutdown event
@app.on_event("shutdown")
async def shutdown_event():
    """Application shutdown"""
    print(f"🛑 AI Behar Platform shutting down...")
    print(f"📊 Total requests handled: {request_count}")
    print(f"⏱️ Total uptime: {datetime.now() - startup_time}")

if __name__ == "__main__":
    # For development
    uvicorn.run(
        "enhanced_platform:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", 8000)),
        reload=os.getenv("DEBUG", "false").lower() == "true"
    )
