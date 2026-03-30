"""Configuration for the LLM Council."""

import os
from dotenv import load_dotenv

load_dotenv()

# OpenRouter API key
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")

# Council members - list of OpenRouter model identifiers
COUNCIL_MODELS = [
    "openai/gpt-5.1",
    "google/gemini-3.1-pro-preview",
    "anthropic/claude-sonnet-4.5",
    "x-ai/grok-4",
]

# Chairman model - synthesizes final response
CHAIRMAN_MODEL = "google/gemini-3.1-pro-preview"

# System prompts
COUNCIL_MEMBER_SYSTEM_PROMPT = """You are a member of an LLM council.
Answer the user's question independently.

Requirements:
- Prioritize accuracy over style.
- Be direct and useful.
- Include nuance only when it materially improves the answer.
- Do not mention the council, other models, or your internal process."""

CHAIRMAN_RANKING_SYSTEM_PROMPT = """You are the Chairman of an LLM council.
You are reviewing anonymized candidate answers from other council members.

Requirements:
- Judge only the quality of the answers you receive.
- Focus on factual accuracy, completeness, clarity, and practical usefulness.
- Be skeptical of confident but weak claims.
- Keep the evaluation concise.
- Follow any required ranking format exactly."""

CHAIRMAN_SYNTHESIS_SYSTEM_PROMPT = """You are the Chairman of an LLM council.
Synthesize the candidate answers into one final response for the user.

Requirements:
- Give the direct answer first.
- Prefer the strongest supported points from the candidate answers.
- Resolve disagreements when possible.
- If uncertainty remains, say so briefly and concretely.
- Do not mention the internal ranking process unless it helps the user."""

TITLE_SYSTEM_PROMPT = """You generate short conversation titles.
Return only a concise title with no quotes and no extra commentary."""

# OpenRouter API endpoint
OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions"

# Data directory for conversation storage
DATA_DIR = "data/conversations"
