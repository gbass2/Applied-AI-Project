## Instance Segmentation Training 

The BDD100K dataset was used for training the segmentation model. A colab notebook is provided with directions taken.

A few extra files are added with some changes required to accomplish the training. 

**build-fix.py** : Needs to replace the build file in the Detectron 2 folder location detctron2/d2/data. Fixes the issue of missing bounding box annotations when converting the segmentation labels into a COCO format json file. 

**demo-fix.py** : Updated demo script to perfrom inference on the YOLOv7-d2 

**train-instanceSeg** : Updated training script for instance segmentation. Adds in registering the dataset for training on Detectron2.

**yolomask-bddk.yaml** : YAML file containing model, training, and dataset specifications
