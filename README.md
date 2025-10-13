# Assessing the Visual Fidelity of Deepfake Videos: Video Fidelity Score (VFS) 

This repository provides a **reproducible** pipeline to compute the **Video Fidelity Score (VFS)** for a **single real** and a **single fake** video.  
The method extracts facial crops, computes **NR-IQA** metrics (BRISQUE + deep IQA models), and summarizes the **distributional difference** (effect size) between real vs fake to yield VFS.

> **Intuition:** Lower VFS means the fake video is **visually closer** to its pristine source (i.e., higher realism).  

---
## 📌 Overview

![VFS pipeline](assets/Proposed_Diagram.png)

*Figure 1:* Illustration of the proposed method. The VFS score is calculated by measuring the distributional difference in NR-IQA scores between fake and real videos.


---

## 🚀 Quick Start

1. **Clone** this repo and prepare your environment (MATLAB + Python).  
2. **Place one real** and **one fake** video.  
3. **Run** the main.m .

The provided demo pair (real and fake videos) is a subset of FaceForensics++ dataset.
⚠️ Note: The example data in `example_videos/` originates from FaceForensics++ and is subject to its dataset license.


![VFS MANIQA of Video125](assets/video_125_maniqa_VFS.png)

*Figure 2:* Facial regions from a sample frame of a real video125 and its manipulated versions, with VFS scores computed via MANIQA.


### Dataset Acknowledgement

The sample videos and example frames provided in this repository are derived from the **FaceForensics++** dataset.

> Rössler, A., Cozzolino, D., Verdoliva, L., Riess, C., Thies, J., & Nießner, M. (2019).  
> *FaceForensics++: Learning to detect manipulated facial images.*  
> In *Proceedings of the IEEE International Conference on Computer Vision (ICCV)*, 1–11.  
> [https://github.com/ondyari/FaceForensics](https://github.com/ondyari/FaceForensics)

All visual examples, videos and cropped faces included here are used **only for research and educational purposes**, following the dataset’s original license and terms of use.

