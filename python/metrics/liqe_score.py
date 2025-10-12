#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan  6 15:51:48 2025

@author: msi
"""
import sys
sys.path.append('/home/msi/anaconda3/envs/matlab_env/lib/python3.9/site-packages')

import pyiqa
import torch
import sys

device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
iqa_metric = pyiqa.create_metric('liqe', device=device)

img_path = sys.argv[1]

score_nr = iqa_metric(img_path)
print('score:', score_nr.item())
