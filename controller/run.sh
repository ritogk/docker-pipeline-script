#!/bin/sh

S3_BUCKET_NAME="${S3_BUCKET_NAME}"
S3_INPUT_DIR="${S3_INPUT_DIR}"
S3_OUTPUT_DIR="${S3_OUTPUT_DIR}"

mkdir -p /storage/input
mkdir -p /storage/output

# 動画のダウンロード
echo "Downloading video from S3..."
aws s3 cp s3://${S3_BUCKET_NAME}/${S3_INPUT_DIR}/ /storage/input/ --recursive

if [ $? -eq 0 ]; then
  echo "Video downloaded successfully."
  touch /storage/dl_complete
else
  echo "Failed to download video from S3." >&2
  exit 1
fi

# 処理完了を待機
while [ ! -f /storage/converting_complete ]; do
  echo "Waiting for converting to complete..."
  sleep 1
done

# 画像のアップロード
echo "Uploading images to S3..."
aws s3 cp /storage/output/ s3://${S3_BUCKET_NAME}/${S3_OUTPUT_DIR}/ --recursive
if [ $? -eq 0 ]; then
  echo "Images uploaded successfully."
else
  echo "Failed to upload images to S3." >&2
  exit 1
fi
