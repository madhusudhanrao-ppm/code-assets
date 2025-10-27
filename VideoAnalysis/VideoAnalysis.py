# This is an automatically generated code sample.
# To make this code sample work in your Oracle Cloud tenancy,
# please replace the values for any parameters whose current values do not fit
# your use case (such as resource IDs, strings containing ‘EXAMPLE’ or ‘unique_id’, and
# boolean, number, and enum parameters with values not fitting your use case).

import oci
from oci.ai_vision.models import *
from time import sleep

# Create a default config using DEFAULT profile in default location
# Refer to
# https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File
# for more info

config = oci.config.from_file("config")

# Specify your compartment OCID
COMPARTMENT_ID = "<Your-compartment-OCID>"
# specify the namespace where the test file is present
NAMESPACE = "<YourNamespace>"
# specify the bucket name where the test file is present
BUCKET = "demo_examples"
# specify the filename of the test video
FILENAME = "VideoAI/DemoVideo.mp4"

# specify the namespace where the output has to be stored
OUTPUT_NAMESPACE = "<your-tenancy>"
# specify the bucket name where the output has to be stored
OUTPUT_BUCKET = "<your-OCI-bucket>"
# specify the prefix where the output has to be stored
OUTPUT_PREFIX = "VideoAnalysis"

# Initialize service client with default config file
video_object_detection_feature = VideoObjectDetectionFeature()
video_face_detection_feature = VideoFaceDetectionFeature()
video_label_detection_feature = VideoLabelDetectionFeature()
video_text_detection_feature = VideoTextDetectionFeature()

# Setting min confidence and max result per frame
video_label_detection_feature.min_confidence = 0.9
video_label_detection_feature.max_results = 20

video_object_detection_feature.min_confidence = 0.9
video_object_detection_feature.max_results = 20

video_text_detection_feature.min_confidence = 0.9

video_face_detection_feature.min_confidence = 0.5
video_face_detection_feature.max_results = 100

# Selected features for video analysis
features = [
    video_label_detection_feature,video_face_detection_feature,video_object_detection_feature,video_text_detection_feature
]

# Getting video file input location
object_location_1 = ObjectLocation()
object_location_1.namespace_name = NAMESPACE
object_location_1.bucket_name = BUCKET
object_location_1.object_name = FILENAME
object_locations = [object_location_1]
input_location = ObjectListInlineInputLocation()
input_location.object_locations = object_locations

# Creating output location
output_location = OutputLocation()
output_location.namespace_name = OUTPUT_NAMESPACE
output_location.bucket_name = OUTPUT_BUCKET
output_location.prefix = OUTPUT_PREFIX

# Creating vision client
ai_service_vision_client = oci.ai_vision.AIServiceVisionClient(config=config)

# Creating input for video job
create_video_job_details = CreateVideoJobDetails()
create_video_job_details.features = features
create_video_job_details.compartment_id = COMPARTMENT_ID
create_video_job_details.output_location = output_location
create_video_job_details.input_location = input_location

# Creating video jobs
res = ai_service_vision_client.create_video_job(create_video_job_details=create_video_job_details)

# Getting job ID and current lifecycle state of video file
job_id = res.data.id
print(f"Job {job_id} is in {res.data.lifecycle_state} state.")

# Tracking job progress
seconds = 0
while res.data.lifecycle_state == "IN_PROGRESS" or res.data.lifecycle_state == "ACCEPTED":
    print(f"Job {job_id} is IN_PROGRESS for {str(seconds)} seconds, progress: {res.data.percent_complete}")
    sleep(5)
    seconds += 5
    res = ai_service_vision_client.get_video_job(video_job_id=job_id)

print(f"Job {job_id} is in {res.data.lifecycle_state} state.")

# Getting object storage client
object_storage_client = oci.object_storage.ObjectStorageClient(config)
object_name = f"{OUTPUT_PREFIX}/{job_id}/{object_location_1.object_name}.json"

# Getting response from object location
video_response = object_storage_client.get_object(OUTPUT_NAMESPACE, OUTPUT_BUCKET, object_name)

# Save output response in output file
file = open('output.json', 'w')
file.write(video_response.data.text)
