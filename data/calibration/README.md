# Calibration Video and xSense-Recording

This folder contains the data used for the calibration of the used approach's step labeling accuracy.
The calibration video was captured to evaluate the accuracy of the step detection heuristic used to automatically label the step start and end.

For that, a video recording and an xSens-Recording were taken at the same time.
Then, steps were labeled in both recordings:
- In the video, this was done manually by optical inspection
- In the awinda recording, this was done with the help of the labeling heuristic as described in the paper.

## Video

The video was captured with a resolution of 1280x720 pixel at 60 Hz.
The step file was created by manually labelling all heel lifts and toe strikes for each foot independenly.

## xSense-Recording

For the xSense-recording that was captured at the same time as the video we used the same setup as we do during the a recording for the data set.
To generate the step data we used our automatic labelling heuristic.

## Comparison of the step labels

The comparison is done by matching the manually labeled step centers of the video to the automatically labeled step centers of the xSense-recording.
This has to be done since the two recording systems are not synchronized and show a clock drift and offset.
Afterwards the mean offset and standard deviation of the manual step starts to the automatic step starts were calculated.
The same was done with the step ends.
