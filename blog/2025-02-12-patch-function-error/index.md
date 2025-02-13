---
title: Bug in Power App
tags: [Power Apps, Patch Function]
---

# Troubleshooting PowerApps: A Step-by-Step Guide to Solving Formula Errors

In today's digital workplace, having the right tools at our disposal is essential. One such tool that has become increasingly valuable is PowerApps. However, like all technology, it's not without its quirks and bugs. Recently, I encountered a challenge with a PowerApp developed by a former colleague. The app utilizes SQL servers stored in our on-premise environment. Now, faced with a lingering bug after his departure, I had no choice but to step in and resolve the issue. Here's how I did it.

## Introduction to the PowerApps Problem

I found myself in a bit of a predicament—a well-crafted PowerApp with a glaring issue. Since the creator had left the company, I was now responsible for diagnosing and fixing a persisting bug. If you find yourself in a similar situation, follow along as I walk you through my troubleshooting process.

<!-- truncate -->

## Diagnosing the PowerApp Bug

The first step in my diagnostic journey was to revisit the PowerApp on my screen. After a bit of preliminary research, I prioritized identifying errors within the application. One of the most effective tools at my disposal was the PowerApps App Checker, a valuable resource for pinpointing potential issues in the application.

Upon utilizing the App Checker, I discovered two formula errors. The first involved the 'patch' function, which had some invalid components linked to another issue. Interestingly, if I resolved one problem, the other would disappear as well. Clicking through led me to the problematic section of the app.

## Fixing the Formula Errors

Facing the formula errors, I zeroed in on the 'patch' function incident. The function requires three arguments: the target of the patch, the value to be patched, and the result of the patch. The function errors were rooted in misconfigured arguments. By carefully reviewing and making necessary adjustments—specifically commenting out irrelevant code sections—I managed to clear the errors without disrupting the app’s integrity.

## Verifying the Solution

With the adjustments in place, I observed the absence of any further errors, confirming that the bug was resolved. The once-troublesome PowerApp was now operating smoothly, a testament to systematic troubleshooting and attention to detail.

## Additional Resources for PowerApps

If you're eager to expand your PowerApps knowledge, I highly recommend resources by Matthew DeWarny. His guides are among the most comprehensive and insightful available for those looking to deepen their understanding of PowerApps. You'll find tutorials covering various functions, including the one we've tackled today.

Matthew’s love for both PowerApps and cats makes his content not only educational but also entertaining. Find his work (and maybe some feline friends) linked in the description of this post.

In conclusion, troubleshooting PowerApps can be challenging, but with a structured approach and the right resources, you can overcome any obstacles. Whether you're dealing with lingering bugs or discovering new functions, keep exploring and learning—every setback is an opportunity for growth.
