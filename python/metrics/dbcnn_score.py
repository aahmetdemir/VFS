import sys
sys.path.append('/home/msi/anaconda3/envs/matlab_env/lib/python3.9/site-packages')

import pyiqa
import torch
import sys

device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
iqa_metric = pyiqa.create_metric('dbcnn', device=device)

img_path = sys.argv[1]

score_nr = iqa_metric(img_path)
print('score:', score_nr.item())