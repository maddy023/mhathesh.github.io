---
date: 2024-11-17
lastmod: 2024-11-17
showTableOfContents: false
tags: ["Tech Conference","AI","Cloud","2024"]
title: "TechXConf 2024: Insights into AI and Cloud Innovations"
categories: ["GenAI"]
series: ["Ollama"]
draft: false
cover:
    image: "/ai/ai-conf-cover.jpeg"
    alt: "Cover"
    caption: ""
    relative: false
---

Attending TechXConf 2024, Asia's largest AI and Cloud conference, was an eye-opener! Over two packed days, I explored groundbreaking topics and tools that left me eager to dive deeper. Here's a quick rundown of three standout sessions that I found particularly fascinating.

----------

### **1. Unleashing the Power of Azure AI with Microsoft Fabric**

**Speaker**: [_Vinodh Kumar_](https://www.linkedin.com/in/vinodh-kumar-173582132/?lipi=urn%3Ali%3Apage%3Ad_flagship3_company_posts%3BIOuOPkD3SB2LFOg0CGJ7gQ%3D%3D) <br>
**Session Theme**: Extracting Insights from Documents

In this session, Vinodh Kumar demonstrated how **Azure Document Intelligence**, integrated with **Microsoft Fabric**, can revolutionize document processing workflows. Using AI-powered tools, you can extract data from complex PDFs or document formats, seamlessly load it into **data lake solutions**, and use it for advanced analytics.

If you’re dealing with document-heavy datasets, this session made it clear that Microsoft Fabric’s integration with AI simplifies data extraction, analysis, and storage.

**Resources to Explore**:

-   [Tutorials on Azure Document Intelligence + Fabric](https://robkerr.ai/fabric-azure-ai-document-intelligence-w2/)
-   [Microsoft Fabric Documentation](https://learn.microsoft.com/en-us/fabric/real-time-intelligence/)

----------

### **2. Let's PenTest the AI Apps**

**Speaker**: [_Samik Roy_](https://www.linkedin.com/in/roysamik/)<br>
**Session Theme**: Exploring Vulnerabilities in AI Applications


This session was a deep dive into **penetration testing for AI apps**, and it was as exciting as it sounds! Samik Roy introduced techniques for testing AI models’ vulnerabilities, focusing on **data poisoning**—injecting incorrect or malicious data to skew the model’s accuracy over time.

What made this session even more intriguing was the speaker’s exploration of other ways to exploit AI systems, leveraging the **ATLAS MITRE Framework**. This framework provides a structured approach to understanding and addressing adversarial threats against machine learning models, offering a comprehensive view of potential vulnerabilities beyond data poisoning.

For organizations building AI applications, adopting frameworks like ATLAS MITRE can help proactively identify and mitigate risks.

![Image alt](/ai/atlas-matrix-ai.png)

One of the session's highlights was a demo of **Counterfit**, an open-source tool by Azure for testing AI security. It’s a must-try for anyone curious about AI application vulnerabilities.

**Resources to Explore**:

-   [Microsoft Blog Counterfit](https://www.microsoft.com/en-us/security/blog/2021/05/03/ai-security-risk-assessment-using-counterfit/)
-   [Counterfit GitHub Repository](https://github.com/Azure/counterfit)
-   [ATLAS MITRE Framework](https://atlas.mitre.org/matrices/ATLAS)


----------

### **3. Secure and Scalable LLAMA Model Deployment in High-Regulation Environments**

**Speaker**: [_Ayyanar Jeyakrishnan_  ](https://www.linkedin.com/in/jayyanar/?lipi=urn%3Ali%3Apage%3Ad_flagship3_company_posts%3BIOuOPkD3SB2LFOg0CGJ7gQ%3D%3D) <br>
**Session Theme**: Deploying AI Models with AWS EKS and NVIDIA NIM

Ayyanar introduced a powerful approach to **deploying and scaling LLAMA models** using **AWS EKS (Elastic Kubernetes Service)** and **NVIDIA NIM Operator**. As someone who currently uses **Ollama** for model deployment, this session offered a compelling alternative.
![Image alt](/ai/nim.png)
The focus was on maintaining scalability and security in high-regulation environments—critical for industries like healthcare and finance. If you’re looking for advanced deployment strategies, experimenting with NVIDIA’s tools could be a game-changer.
![Image alt](/ai/nim-2.jpeg)

**Resources to Explore**:

-   [NVIDIA NIM Operator GitHub Repository](https://github.com/NVIDIA/k8s-nim-operator)

---------


### **4. An Era of Multi-Agent LLM in Banking: Anti-Money Laundering**

**Speaker**: [_Dr. Anusuya Kirubakaran_](https://www.linkedin.com/in/dr-anusuya-kirubakaran-b6ab37117/?lipi=urn%3Ali%3Apage%3Ad_flagship3_company_posts%3BIOuOPkD3SB2LFOg0CGJ7gQ%3D%3D) <br>
**Session Theme**: Multi-Agent LLM Models

This session tackled a critical issue in banking: **Anti-Money Laundering (AML)**. Dr. Anusuya highlighted the challenges faced by regulatory authorities and the innovative use of **multi-agent Large Language Models (LLMs)** to streamline and enforce compliance.

One fascinating example shared was around **fuzzy name matching** in transaction monitoring. For instance, if a bank account holder is named "Mhathesh" but the transaction is logged under "Madesh," the LLM uses **fuzzy search models with Retrieval-Augmented Generation (RAG)** to identify discrepancies and flag them.

Dr. Anusuya explained how AML operations are broken down into **critical components**, such as:

![Image alt](/ai/alm.jpeg)

-   Customer Identification ✅
-   Sanctions and Watchlist Screening 🔍
-   Negative News/Adverse Media Analysis 📜
-   Transaction Monitoring 💳
-   Enhanced Due Diligence for Politically Exposed Persons (PEPs) 🕵️

Each of these components is managed by individual LLM agents, which collaborate to create a comprehensive anti-money laundering system. By leveraging this multi-agent approach, banks can achieve higher accuracy and regulatory compliance while reducing false positives.

---

### **5. Building High-Performance Rendering Engines for AR/VR/XR**

**Speaker**: [_Preetish Kakkar_](https://www.linkedin.com/in/preeteesh/?lipi=urn%3Ali%3Apage%3Ad_flagship3_company_posts%3BIOuOPkD3SB2LFOg0CGJ7gQ%3D%3D)<br>
**Session Theme**: Leveraging AI and Cloud for Next-Gen Graphics in AR/VR/XR

In this visually captivating session, Preetish Kakkar shed light on how cutting-edge **AI models** and **cloud technologies** are revolutionizing rendering engines for AR/VR/XR applications. The session focused on enhancing both **performance** and **efficiency** in creating immersive virtual environments.

Preetish introduced how **open graphic models** like **Vulkan** and **OpenGL** form the backbone of AR/VR rendering engines. The real highlight was the incorporation of **NeRF AI models (Neural Radiance Fields)** to enable **real-time, dynamic 3D generation** from 2D images. Imagine creating 3D scenes with perspectives that adjust dynamically as if you’re actually moving through the environment—it’s a whole new paradigm for rendering!

<video width="100%" height="100%" controls src="http://cseweb.ucsd.edu/~viscomp/projects/LF/papers/ECCV20/nerf/website_renders/depth_ornament.mp4" title="video"></video>

The session also dived into **NVIDIA’s DLSS (Deep Learning Super Sampling)** technology, which uses AI to upscale images from lower resolutions (e.g., 1K) to ultra-high resolutions like 8K. This breakthrough significantly reduces the need for massive computational power and high-end GPUs to render 4K textures, making high-resolution rendering accessible for more users without compromising on visual fidelity.

**Resources to Explore**:

-   [NeRF: Neural Radiance Fields](https://nerf-wiki.com)
-   [NVIDIA DLSS Documentation](https://www.nvidia.com/en-us/geforce/technologies/dlss)
-   [Vulkan Graphics API](https://vulkan.org)

---

### **Conclusion: A Glimpse into the Future of AI and Cloud Innovations**

As we step away from TechXConf 2024, one thing is clear: **AI and cloud aren’t just buzzwords—they’re the future.** Whether you’re in banking, security, data engineering, or immersive tech, these tools are here to help you build smarter, faster, and more innovative systems.