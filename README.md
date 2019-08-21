## Step 1: Prepare Images

First, you want to make the directory containing your images your working directory in MATLAB.

```matlab
cd ''
```
Next, you want to prepare the images

```matlab
cd segmentations_nuclei
```

## Step 2: Segment Structures (Nuclei, Lumens, Organoid, Buds)

Note that steps 2 and 3 can be completed in any order. 

The instructions in this section can be used to segment nuclei, lumens, organoid, or buds. These structures can be segmented in any order (for example, you can segment buds before or after segmenting the organoid, etc), but you must follow the steps in order (for example, must complete step 2 before step 3, etc). 

The structures you want to segment depend on the type of organoid. For MDCK organoids you will want to segment nuclei, lumens, and organoid. For Intestine organoids you'll want to segment lumens, organoid, and buds. 

First, you want to create a folder to store the files that will contain the segmentations for each image. Let's pretend we want to segment some nuclei. 

Make that file your working directory.

```matlab
cd segmentations_nuclei
```

#### Step 2A: Guess 2D Segmentations

```matlab
organoids2.guess_2D_segmentations;
```

<details>
	<summary>How does it work?</summary>
	OH LET ME TELL YOU
</details>
	
#### Step 2B: Prepare 2D Segmentations for Review
#### Step 2C: Review 2D Segmentations
#### Step 2D: Guess 3D Segmentations
#### Step 2E: Prepare 3D Segmentations for Review
#### Step 2F: Review 3D Segmentations

## Step 3: Identify Cell Types

Note that steps 2 and 3 can be completed in any order. 

This applies only to Intestine organoids (MDCK organoids are all the same cell type). 

## Step 4: Collect All Segmentations

Once you have completed steps 2 and 3, you are ready to measure the features of these segmentations! But first we must collect all the data. 

<details>
	<summary>How does it work?</summary>
	OH LET ME TELL YOU
</details>

## Step 5: Measure Features
