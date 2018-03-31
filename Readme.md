# MailPhys_analysis

This is the Matlab analysis component for the MailPhys project. The user-facing, data collection component can be found on [https://github.com/ForSubmission/MailPhys](https://github.com/ForSubmission/MailPhys).

# Usage

Analysis requires *source* data, obtained from MailEye and Shimmer sensors.

The *source* data files are CSV (for Shimmer data) and JSONs contained within `MAIL` folders (for MailEye data). These should be in the format `GSR_P01_S1.csv`, `EMG_P01_S1.csv`, `MAIL_P01_S1_A1`, `MAIL_P01_S1_A2`, etc., where P is followed by the participant number, S with the session number, and A with the account number (only for mail folders).

Once these data are collected, we preprocess the data and perform classification on them, by following the steps below. The procedure is broken into steps in order to be more modular (so it can be iteratively improved without repeating the whole pipeline, which could be time-consuming). 

The steps are

1. [Preprocessing 1](#preprocessing-1-gsr) (just for GSR data)
2. [Preprocessing 2](#preprocessing-2-aggregation) (Aggregation and conversion into features)
3. [Table creation](#table-creation)
4. [Classification](#classification)

All these steps output intermediate data and results in `~/MATLAB/MailPhys`, where `~` stands for the user's home folder. `~/MATLAB` is defined in [Params.m](Params.m) as `basedir` and can be changed to another location (Windows users might especially want to do this, since `~` is not defined under all Windows installations). `Params.outdir` specifies that we want to save outputs under the `MailPhys` subdirectory of `basedir` (this can also be changes as preferred).

## Preprocessing 1 (GSR)

We preprocess GSR files using Ledalab. We will obtain an EDA mat file for the following step (aggregation).

As soon as all data is collected, run [preprocess_eda.m](preprocess_eda.m) and point to a Shimmer CSV (GSR) file. This will convert GSR data into a format understood by Ledalab, then runs Ledalab on the created data. 

The data will be saved in the target directory (defined in `Params.outdir`, e.g. `~/MATLAB/MailPhys`), subdirectory `edatemp`.

`preprocess_eda` can be run *without* arguments (a file selection window will appear) or with arguments, for example:

```
preprocess_eda('/Users/username/Google Drive/MailPhys/Data/Participant 1 - training/GSR_P01_S4.csv');
```

this will generate a `EDA_P01_S4.mat` file in `edatemp`. Move this file back with the original CSV files and MAIL folders for the participant.

Data should then be ready to be aggregated (next step).

## Preprocessing 2 (Aggregation)

After preprocessing, data is aggregated, so that we generate a JSON file for each message that the user read. For each JSON, we add physiological and accelerometric data related to the given mail (obtained from the Shimmer files and the EDA mat file).

Run `aggregateData` pointing to the folder that contains all the source data (with a parameter specifying the directory or without a parameter to pop-up a folder selection window). The selected folder must contain data in CSV files, EDA MAT file (added in the previous step) and MAIL directories. They should be organised in this format.

```
EDA_P01_S1.mat
EDA_P01_S2.mat
EMG_P01_S1.csv
EMG_P01_S2.csv
GSR_P01_S1.csv
GSR_P01_S2.csv
MAIL_P01_S1_A1
MAIL_P01_S2_A1
``` 

Where P01 is the participant number, S1 the session number. MAIL folders also have an account number; A1 is mandatory, then additional accounts can be separated by using A2, A3 and so on.

Running aggregateData on this dataset will create a new directory called `P01` (where 01 is the participant number) under the target directory (`Params.outdir`). In the `P01` directory, a JSON file will be created for each message, in chronological order (in the original order that the user read the messages). Two JSON files containing raw data will also be created here. The outputted data is defined in the [Data specification](#data-specification) section below.

## Table creation

Once the data is split into individual json files (named `0.json`, `1.json`, ...) it can be read and saved into a table using [writeTable.m](writeTable.m). The table will be called `tab` and saved into `datatable.mat` in the same directory we point `writeTable` to (we can pass a parameter to specify the target location, or run without parameters to pop-up a folder selection window).

```
writeTable('~/MATLAB/MailPhys/P01');
```

## Classification

Once the procedure has been run for at least one participant, we run the classifier, and also run a randomisation test to make sure that the first classification performed significantly better than chance.

To do this, we run [saveResults.m](saveResults.m), which will run the classifier and output the results of the randomisation tests in the target folder. This requires the participant number and the number of randomisation iterations we prefer.

For example:
```
saveResults(1, 500)
```

will run the test for participant 1 (automatically translated `P01` under the target directory specified in `Params.outdir`). The results will be saved in the target directory, under `results_P01_500`.

If we run this procedure for a few participants, we can then run [finalTableMaker.m](finalTableMaker.m) specifying a vector of participant numbers and a number of iterations parameter, for example:

```
finalTableMaker([1 2 3 4], 500)
```

will parse through all the needed `results_PXX_500` folders (where PXX is the participant number) and compute a final table that summarises all randomisation results for all the given participants under the `results_final_500 folder`. This final table will be called `finalTable.csv` and will be outputted in the target directory. It will contain how often a given feature set was significant and which was its average AUC. Feature sets are defined in [SetCollection.m](SetCollection.m). It will also output a `participantTable.csv`, which report which was the "best" feature set for each participant (i.e. the feature set that obtained the highest AUC for that participant).

# Data specification

each JSON corresponds to an AugmentedMessage (as defined in [https://github.com/ForSubmission/MailPhys](https://github.com/ForSubmission/MailPhys)).

## JSON Fields

### User labels

```
pleasure - number from 1 to 4 indicating how pleasant was this message (all these labels could be split into binary classification so that if > 2.5 == 1 otherwise 0)

priority - 1 to 4, how important was this message

workload - 1 to 4, how much work it took to deal with this message

spam - 1 if spam (might be interesting to classify spam based on physio data)

wasUnread - binary, 1 if message was initially unread, 0 if the participant read this before (we could discard all messages for which this is 0)

eagerlyExpected - binary, 1 if the participant was eagerly expecting this message (there’s not many of these)

corrupted - binary, 1 if text was corrupted (should discard all corrupted messages)
```

### MailEye automatic labels

```
containsAttachment - binary, 1 if attachments were present

session - session number, just in case

account - account number, just in case

bodySize - how big the message was overall, in pixels (including offscreen text)
```

### Physiological data

```
rawEyeData - matrix of all raw eye data, contains Xs, Ys and Ts (timepoints in nanoseconds)

eda - EDA data and accelerometer data on wrist, contains
       accX - raw data for x axis
       accY - raw data for y axis
       accZ - raw data for z axis
	* the above also have _n variants calculated on normalised data
       accel - sum of all raw accelerometer data
       accelSum - sum of raw accelerometer data
	raw - raw gsr data
       phasic - phasic driver, should contain a representation of how much the fingers were sweating at each timepoint
       phasicSum - summation of phasic driver, i.e. total sweating (arousal) for that message. Might correlate to priority

emg - facial EMG and accelerometer data on head, contains
       accel, accelSum, accX, accY, accZ (similar to what eda contains but on head)
       corrugator - normalised data from corrugator supercili (eyebrow - concentration)
       zygomaticus - normalised data from zygomaticus major (cheek - smiling)
       corrSum - summation of currugator data
       zygoSum - summation of zygomaticus data
	* the above also have _n variants calculated on normalised data

gazes - fixations detected in various boxes, contains
       body - fixations in body of message
       thread - fixations in thread (left hand side) related to this message
       reference - fixations in reference view (related messages) related to this message
       header - fixations in header (sender, subject, time). Each box contains
               x, y - coordinates of fixation
               unixtime - when fixation took place (milliseconds from 1/1/1970)
               duration - fixation duration in ns

keywords - which words the user looked at (or looked nearby), each entry contains
       name - hash of keyword (so we don’t spy into the user data, but might be used to correlate keywords)
       gazedurations - duration of each fixation that took place on or near this keyword
       length -  original length of word
```

### Behavioural data

```
clickActivity - represents “chunks” of mouse clicks (one entry represents the amount of mouse clicks that took place in a 2s interval, if any)

pointerActivity - represents chunks of mouse movements (hypotenuse of x y mouse location travel within a 2s interval)

keyboardActivity - how many key presses occurred in a 5s interval (one entry per chunk)

visits - when and how many times the user visited this message (start and end unixtime per visit)

selections - one entry gets created every time the user highlights some text in the message, contains
       endTime - time representing when selection ended (we have no start time)
       nOfCharacters - how many characters were selected
```
       
## Full raw data

Apart from JSON numbered files, these files are also outputted, containing the entire data stream.

```
emgData.json
	time - unix time, ms from 1/1/1970 when this sample was taken
	accelX, accelY, accelZ - accelerometer data from head
	corr - corrugator supercili muscle
	zygo - zygomaticus major muscle

gsrData.json
	time, accelX, accelY, accelZ - same as above but accelerometer data is from wrist
	gsr - raw skin conductance
	phasic - phasic driver (should be more informative than raw gsr)
```
