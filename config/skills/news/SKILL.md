---
name: news
description: Gagik's tech news brief — a short, sourced list of the most important news from the last 10 days about Silicon Valley, NASA, SpaceX, OpenAI, Anthropic/Claude, Tesla, Meta and other top tech newsmakers. Use whenever the user says "give me a news" (any case/punctuation, e.g. "give me news", "give me the news").
---

# News brief

Triggered by **"give me a news"**. Search the web, then reply with a short list. No follow-up questions — just do it.

## Window

The **last 10 days**, counted back from today's date. Skip anything older, even if it ranks high in search results. Check each story's publish date.

## Topics (search each one)

1. Silicon Valley — big tech, startups, funding rounds, layoffs, acquisitions, regulation
2. NASA — missions, launches, Artemis, discoveries
3. SpaceX — Starship, Falcon launches, Starlink
4. OpenAI — models, products, deals, leadership
5. Anthropic / Claude — models, products, Claude Code, deals
6. Tesla — products, FSD/robotaxi, Optimus, earnings, Elon Musk
7. Meta — AI models, products, Reality Labs, legal
8. Top newsmakers — whatever else is dominating tech headlines (Google, Apple, Microsoft, Nvidia, Amazon, xAI, chips, AI policy, ...)

Run the searches in parallel (one or two per topic, add the month and year to the query). Prefer primary sources (company blogs, nasa.gov, spacex.com) and reputable outlets (Reuters, AP, Bloomberg, The Verge, TechCrunch, CNBC, Ars Technica, Wired). Don't invent or guess: every item needs a link you actually found.

## Output

A heading per topic, 1–3 bullets each, most important first. Each bullet is one line:

```
- **Headline in a few words** — one-sentence summary. ([Source](https://...), Oct 18)
```

- Keep the whole brief short — about 15–25 bullets total.
- If a topic had no notable news in the window, write "Nothing major in the last 10 days."
- End with a **Top 3** line: the three stories that matter most.
- Write it in chat; don't create files.
