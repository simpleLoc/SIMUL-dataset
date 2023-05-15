# SIMUL: Synchronized IMU Dataset of Walking People at Six Body Locations

This work presents [SIMUL](https://simpleloc.github.io/SIMUL-dataset/), a new dataset consisting of 550 minutes of annotated motion data from six synchronized IMUs placed consistently at the same strategically chosen positions on the bodies of 32 participants. With a focus on indoor localization, the selection fell on hand, feet, and trouser pockets. Due to the sensor's synchronization, this selection allows, for example, to label the data recorded in the hand based on the data captured at the feet. For a better generalizability, the dataset was recorded freestyle under many different environmental conditions and walking speeds. Thus, indoors, numerous floor coverings such as stone, wood, carpet and PVC, as well as stairs are included in the data.  The outdoor recordings additionally contain uneven surfaces such as paving stones and slopes. The annotation of the participant's currently performed activity additionally allows this dataset to be used for activity recognition.

# File structure

## .csv
CSV-Files contain the raw data of a recording.
Columns:
- **Timestamp**: Timestamp in seconds when the sample was recorded
- **Activity**: Activity that was performed when capturing this sample
- **Accel{X,Y,Z}_**$n$: Accelerometer readings in the direction of the {x,y,z}-axis of the n-th IMU
- **FreeAccel{X,Y,Z}_**$n$: Gravity-free accelerometer readings in the direction of the {x,y,z}-axis of the n-th IMU
- **Gyro{X,Y,Z}_**$n$: Angular rate around the {x,y,z}-axis of the n-th IMU
- **Magn{X,Y,Z}_**$n$: Magnetometer readings of the {x,y,z}-axis of the n-th IMU
- **Quat{W,X,Y,Z}_**$n$: Rotation quaternion of the n-th IMU relative to the world system calculated by the IMU
- $n \in \{1,2,3,4,5,6\}$: IMU device numbers from 1 to 6, where (1) left foot, (2) right foot, (3) left front pocket, (4) right front pocket, (5) handheld IMU, (6) back pocket

## .step
**step**-Files contain the step annotations for each step done in the recording with the same file name. The content is a 3-by-m matrix where each row is one step. The step start sample indices are in the first column, the step end indices in the second column and the last column tells whether it is a left (0) or right (1) step.

## .stepNonoverlap
**stepNonoverlap**-Files containing the non-overlapping steps. This file structure is similar to the **step**-File structure, but there is no column for the left or right foot label.

# Directory structure

## data/by-person
This directory contains all recordings grouped by the participant and their respective step annotations.

## src
The source directory contains Octave scripts view and annotate the data.

### toolEditActivity
With this tool the activities of a recording can be viewed and manipulated. Clicking on save will overwrite the file opened.

### toolLabelSteps
This tool automatically generates the **step**-File to a recording given. The labels can be corrected by hand afterwards.

### generateNonOverlappingSteps
Using this tool you can convert the **step**-Files to **stepNonoverlap**-Files.

# How to use

## Matlab / Octave
```matlab
% Recording definitions: 6 IMUs with 16 sensor channels each
DEVICE_CNT = 6;
DATA_COLUMNS_PER_DEVICE = 16;
% Sensor channel access indices
DIMS_ACCELEROMETER = 1:3;
DIMS_FREE_ACCELERATION = 4:6;
DIMS_GYROSCOPE = 7:9;
DIMS_MAGNETOMETER = 10:12;
DIMS_QUATERNION	= 13:16;

% Load the data recording, as well as the step annotation data
rawData = dlmread('data/by-person/0/awindaRecording_20230425111726.csv', ',', 1, 0);
stepRegions = dlmread('data/by-person/0/awindaRecording_20230425111726.csv.step');
recordingTimestamps = rawData(:, 1);
recordingActivities = rawData(:, 2);
% Parse the individual device's data into a cell of matrices
deviceData = cell(1, DEVICE_CNT);
for(deviceIdx = 1:DEVICE_CNT)
	offsetIdx = 3 + (deviceIdx - 1) * DATA_COLUMNS_PER_DEVICE;
	deviceData{deviceIdx} = rawData(:, offsetIdx:(offsetIdx + DATA_COLUMNS_PER_DEVICE - 1));
end

% Plot the first device's accelerometer and gyroscope readings (left foot)
dataOfFirstDevice = deviceData{1};
accelerometer = dataOfFirstDevice(:, DIMS_ACCELEROMETER);
gyroscope = dataOfFirstDevice(:, DIMS_GYROSCOPE);
figure('name', 'Left Foot: Accelerometer');
plot(accelerometer); legend('x', 'y', 'z');
figure('name', 'Left Foot: Gyroscope');
plot(gyroscope); legend('x', 'y', 'z');

% Extract and print contained steps for the left foot
leftFootSteps = stepRegions(stepRegions(:, 3) == 0, 1:2)
% Extract and print contained steps for the right foot
rightFootSteps = stepRegions(stepRegions(:, 3) == 1, 1:2)
```

## Python
To load a recording with pandas in python use:
```python
import pandas

# load recording with activities and IMU data
data = pandas.read_csv("data/by-person/0/awindaRecording_20230425111726.csv")

# load step data for the same recording
steps = pandas.read_csv("data/by-person/0/awindaRecording_20230425111726.csv.step", header=None)

# print the timestamps of the recording
print(data["Timestamp"])

# Sensor channel access indices
DIMS_ACCELEROMETER = range(2,5)
DIMS_FREE_ACCELERATION = range(5,8)
DIMS_GYROSCOPE = range(8,11)
DIMS_MAGNETOMETER = range(11,14)
DIMS_QUATERNION = range(14,18)

# print the accelerometer readings of the left foot sensor
print(data.iloc[:, DIMS_ACCELEROMETER])

# print the gyro readings of the left foot sensor
print(data.iloc[:, DIMS_GYROSCOPE])

# print only right steps
print(steps[steps[2] == 1])
```
