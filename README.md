# Applied-AI-Project

## Summary:
This project implemented a autonomous driving object detector using [YOLOv7](https://github.com/WongKinYiu/yolov7) and the [Udacity](https://public.roboflow.com/object-detection/self-driving-car) dataset. The model was converted to Core ML after training and inference was ran on an iPhone 13 Pro.

## Included:
  - [iOS App](app)
  - [Core ML and PyTorch models](models)

## Results:
![Single Image Inference](documentation/images/test1.PNG "Single Image Inference")
![Single Image Inference](documentation/images/test2.PNG "Single Image Inference")

[![Live Results](https://res.cloudinary.com/marcomontalbano/image/upload/v1670026267/video_to_markdown/images/google-drive--10a2BTmvDLUOKnZi87EzzWlVNz52qLRwm-c05b58ac6eb4c4700831b2b3070cd403.jpg)](https://drive.google.com/file/d/10a2BTmvDLUOKnZi87EzzWlVNz52qLRwm/view?usp=share_link "Live Results")

## Notes:
The app works best when the device is oriented in the landscape position with camera facing to the left. The apps framerate has been limited to 60 fps since the model could no exceed that. The maximum framerate supported from the camera is 240 fps.
