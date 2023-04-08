import uvicorn
import asyncio
import main

async def serv():
    config = uvicorn.Config("main:app", reload=True, host='127.0.0.1', port=8000, log_level="debug")
    server = uvicorn.Server(config)
    await server.serve()

if __name__ == "__main__":
    asyncio.run(serv())
