---
description: Research and analyze a topic comprehensively, output as structured report
argument-hint: [topic or question to investigate]
---

# Deep Mode - Comprehensive Research Report

Conduct a thorough, multi-angle investigation of the given topic and produce a structured research report.

## Instructions

1. **Define the Scope**
   - Parse the research topic: $ARGUMENTS
   - Clarify what aspect the user is most interested in
   - If the scope is too broad, propose a focused angle before proceeding

2. **Research Phase**
   - Use WebSearch to gather current information (use year 2026 for recent data)
   - Use Context7 MCP if the topic involves libraries or technical tools
   - Cross-reference multiple sources for accuracy
   - Look for both mainstream views and contrarian perspectives

3. **Analysis Phase**
   Apply multiple analytical lenses:

   ### Current State (現状)
   - What exists today? What's the baseline?
   - Key players, tools, approaches in the space
   - Market/ecosystem maturity level

   ### Challenges (課題)
   - What problems remain unsolved?
   - What are the common pain points?
   - Where do existing approaches fall short?
   - Technical limitations and constraints

   ### Options & Approaches (打ち手)
   - What solutions or strategies exist?
   - Compare approaches with trade-offs
   - Identify emerging trends or promising directions
   - Highlight unconventional or overlooked options

   ### Risks & Considerations (リスク・留意点)
   - What could go wrong?
   - Dependencies and assumptions
   - Areas of uncertainty

4. **Produce the Report**
   Output in this structure:

   ```markdown
   # [Topic] 調査レポート

   ## エグゼクティブサマリー
   (3-5 sentences capturing the key findings)

   ## 1. 背景・現状
   (Current state analysis)

   ## 2. 課題の整理
   (Structured breakdown of challenges)

   ## 3. 打ち手の比較
   | 観点 | Option A | Option B | Option C |
   |------|----------|----------|----------|
   | ...  | ...      | ...      | ...      |

   ## 4. 推奨アプローチ
   (Your recommendation with rationale)

   ## 5. リスクと留意点
   (Risks, caveats, and areas needing further investigation)

   ## 6. Next Steps
   (Concrete actions the user can take)

   ## Sources
   (List of references and links)
   ```

## Quality Standards

- **Factual**: Cite sources. Don't fabricate data or statistics
- **Balanced**: Present multiple viewpoints, not just one narrative
- **Actionable**: End with concrete next steps, not just analysis
- **Concise**: Dense with insight, not padded with filler
- **Current**: Prioritize recent information (2025-2026)

## Output Language

- Write the report in Japanese
- Technical terms can remain in English where natural (e.g., "CI/CD", "microservices")

## Anti-Patterns

- Don't produce a shallow overview — go deep on the aspects that matter
- Don't list every possible option — curate and compare the most relevant ones
- Don't hide uncertainty — explicitly state confidence levels where appropriate
- Don't skip the recommendation — the user wants your informed opinion, not just data
