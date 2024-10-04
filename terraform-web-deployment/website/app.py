
from flask import Flask, render_template, request, redirect, url_for
import boto3
import os
from werkzeug.utils import secure_filename

# AWS S3 configuration
S3_BUCKET = "my-bucket-terraform-deployment-30092024"
S3_REGION = "eu-west-3"  # e.g., "eu-west-3"
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

# Initialize Flask app
app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads/'

# Initialize S3 client
s3 = boto3.client('s3', region_name=S3_REGION)

def allowed_file(filename):
    return '.' in filename and \
        filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
def upload_form():
    return '''
    <html>
    <body>
        <h1>Upload Image</h1>
        <form method="post" enctype="multipart/form-data" action="/upload">
            <input type="file" name="file">
            <input type="submit" value="Upload">
        </form>
    </body>
    </html>
    '''

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return "No file part"
    file = request.files['file']
    if file.filename == '':
        return "No selected file"
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        
        # Save file locally
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
        
        # Upload to S3
        s3.upload_file(file_path, S3_BUCKET, filename)
        
        # Remove the local file
        os.remove(file_path)

        return f"File uploaded successfully to S3: {filename}"
    else:
        return "Invalid file type"

if __name__ == "__main__":
    app.run()
