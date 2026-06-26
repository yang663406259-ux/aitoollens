$ErrorActionPreference = "Stop"

$SiteRoot = "E:\project\hoomen\aitoolreview"
$ContentDir = "$SiteRoot\content\posts"
$LogFile = "$SiteRoot\auto-publish.log"

function Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts - $msg" | Out-File $LogFile -Append -Encoding UTF8
    Write-Host "$ts - $msg"
}

Log "=== Daily Auto-Publish START ==="

# Step 1: Search trending AI topics
Log "Step 1: Searching trending AI topics..."
$searchQueries = @(
    "new AI tool launch 2026",
    "AI software update June 2026",
    "best AI tool this week 2026",
    "AI startup funding 2026",
    "AI app review 2026"
)

$topics = @()
foreach ($q in $searchQueries) {
    try {
        $encoded = [uri]::EscapeDataString($q)
        $url = "https://news.google.com/rss/search?q=$encoded&hl=en-US&gl=US&ceid=US:en"
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
        $xml = [xml]$resp.Content
        $items = $xml.rss.channel.item | Select-Object -First 5
        foreach ($item in $items) {
            $title = $item.title -replace '<[^>]+>',''
            $link = $item.link
            $pubDate = $item.pubDate
            if ($title -and $title -match 'AI|artificial intelligence|machine learning|chatbot|LLM|GPT|Claude|Gemini|Copilot') {
                $topics += @{ title = $title; link = $link; date = $pubDate }
            }
        }
    } catch {
        Log "  Search query '$q' failed: $($_.Exception.Message)"
    }
}

if ($topics.Count -eq 0) {
    Log "No trending topics found. Using fallback topics..."
    $fallbackTopics = @(
        "Latest AI productivity tools released this month",
        "New AI coding assistants comparison 2026",
        "AI image generation updates and new features",
        "Best AI writing tools for content creators",
        "AI video editing tools getting better in 2026"
    )
    $i = 0
    foreach ($ft in $fallbackTopics) {
        $topics += @{ title = $ft; link = ""; date = (Get-Date).ToString() }
        $i++
        if ($i -ge 3) { break }
    }
}

$selectedTopic = $topics | Get-Random
$topicTitle = $selectedTopic.title
$topicLink = $selectedTopic.link
Log "Selected topic: $topicTitle"

# Step 2: Generate article content (template-based, no API needed)
Log "Step 2: Generating article..."

$today = Get-Date -Format "yyyy-MM-dd"
$slug = ($topicTitle -replace '[^a-zA-Z0-9\s-]','' -replace '\s+','-' -replace '-+','-').Trim().ToLower()
if ($slug.Length -gt 80) { $slug = $slug.Substring(0,80) }
if ($slug.EndsWith("-")) { $slug = $slug.TrimEnd("-") }
$filePath = "$ContentDir\$slug.md"

# Avoid duplicates
if (Test-Path $filePath) {
    $slug = "$slug-$(Get-Random -Minimum 100 -Maximum 999)"
    $filePath = "$ContentDir\$slug.md"
}

$tags = @("ai-tools","ai-trends","2026")
if ($topicTitle -match "code|developer|copilot|cursor") { $tags += "ai-coding" }
if ($topicTitle -match "image|midjourney|dall-e|design") { $tags += "ai-image" }
if ($topicTitle -match "video|editing|runway") { $tags += "ai-video" }
if ($topicTitle -match "write|content|blog") { $tags += "ai-writing" }
if ($topicTitle -match "chatbot|GPT|claude|gemini") { $tags += "ai-chatbot" }
if ($topicTitle -match "voice|speech|elevenlabs") { $tags += "ai-voice" }
if ($topicTitle -match "music|audio|suno") { $tags += "ai-music" }
if ($topicTitle -match "business|enterprise|startup") { $tags += "business" }

$category = if ($topicTitle -match "vs|versus|compare|comparison") { "Comparisons" } elseif ($topicTitle -match "guide|how to|best|top") { "Guides" } else { "Reviews" }

$tagsStr = ($tags | Select-Object -First 5 | ForEach-Object { "`"$_`"" }) -join ", "

$articleContent = @"
---
title: "$($topicTitle -replace '"','`"')"
date: $today
lastmod: $today
categories: ["$category"]
tags: [$tagsStr]
summary: "A closer look at $("$($topicTitle -replace '"','')"). We examine what's new, what works, and whether it's worth your attention in 2026."
ShowToc: true
draft: false
---

# $($topicTitle -replace '"','')

The AI landscape continues to evolve rapidly, and $($topicTitle -replace '"','') has been generating significant attention. In this article, we break down the key developments and what they mean for users.

## What's New

Recent developments in this area have brought several notable changes:

- **Improved performance** — Tools are getting faster and more accurate with each update
- **Better integration** — Ecosystem connectivity continues to improve across platforms
- **Lower costs** — Competitive pressure is driving prices down across the industry
- **New capabilities** — Features that were premium-only are becoming standard

## Key Features to Watch

### 1. Enhanced AI Models

The underlying models powering these tools have improved significantly. Better training data, refined architectures, and optimized inference mean outputs are more useful and reliable than ever.

### 2. Workflow Automation

More tools now offer end-to-end automation rather than point solutions. Instead of using five separate tools, a single platform handles research, drafting, editing, and publishing.

### 3. Collaboration Features

Team-oriented features have become a key differentiator. Real-time collaboration, role-based permissions, and shared workspaces make these tools viable for organizations, not just individuals.

## How It Compares

When evaluating this against alternatives, consider these factors:

| Factor | This Tool | Industry Average |
|--------|-----------|-----------------|
| **Ease of use** | High | Medium |
| **Value for money** | Good | Moderate |
| **Integration** | Strong | Varies |
| **Learning curve** | Low | Medium |

## Who Should Pay Attention

This development matters most for:

- **Content creators** looking for efficiency gains
- **Small teams** needing to do more with less
- **Enterprise users** evaluating vendor options
- **Developers** building on AI platforms

## What's Still Missing

No tool is perfect. Current limitations include:

- Occasional inaccuracies in AI-generated content
- Privacy concerns with cloud-based processing
- Pricing that scales poorly for large teams
- Vendor lock-in risks with platform-specific tools

## Looking Ahead

The AI tools market is moving toward consolidation, better integration, and lower costs. Expect significant updates every quarter. We'll continue monitoring and update this analysis as new features ship.

## Final Thoughts

$($topicTitle -replace '"','') represents meaningful progress in the AI tools landscape. While not revolutionary, the incremental improvements are making these tools more practical for everyday professional use.

We recommend testing it alongside your current tools before making any switches.

**Rating: 7/10** — Solid incremental progress worth evaluating.

---

*You might also like: [Best AI Writing Tools 2026](/posts/best-ai-writing-tools-2026/) | [ChatGPT vs Claude](/posts/chatgpt-vs-claude-2026/) | [Ultimate AI Tools Stack](/posts/ultimate-ai-tools-stack-solopreneurs-2026/)*
"@

Set-Content -Path $filePath -Value $articleContent -Encoding UTF8
Log "Article created: $filePath"

# Step 3: Build Hugo site
Log "Step 3: Building Hugo site..."
$buildResult = & hugo --minify --source $SiteRoot 2>&1
$buildExit = $LASTEXITCODE
Log "Build exit code: $buildExit"
if ($buildExit -ne 0) {
    Log "BUILD FAILED! Aborting."
    Log $buildResult
    exit 1
}

# Step 4: Git commit and push
Log "Step 4: Committing and pushing..."
Set-Location $SiteRoot
git add -A
$commitMsg = "auto: publish article $($slug) ($today)"
git commit -m $commitMsg 2>&1 | Out-Null
git push origin main 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Log "Push SUCCESS! Article: $slug"
} else {
    Log "Push FAILED!"
    exit 1
}

Log "=== Daily Auto-Publish COMPLETE ==="
