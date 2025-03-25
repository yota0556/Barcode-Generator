import os
import io
from flask import Flask, request, send_file, render_template, Blueprint
import barcode
import base64
from barcode.writer import ImageWriter

bp = Blueprint('main', __name__)

@bp.route('/')
def index():
    return render_template('index.html')

@bp.route('/barcode')
def generate_barcode():
    # Retrieve the barcode data; default to a sample value if not provided
    text = request.args.get('text', '123456789012')
    # Retrieve the optional barcode name (raw input for display)
    user_name = request.args.get('name', '').strip()
    # Create a download name by appending .png if a name is provided; otherwise use a default filename
    download_name = f'{user_name}.png' if user_name else 'barcode.png'
    
    # Generate a Code128 barcode (flexible for various input strings)
    barcode_class = barcode.get_barcode_class('code128')
    my_barcode = barcode_class(text, writer=ImageWriter())
    
    # Write the generated barcode image to an in-memory bytes buffer
    buffer = io.BytesIO()
    my_barcode.write(buffer)
    buffer.seek(0)
    
    # Convert the image bytes to a Base64 string for embedding in HTML
    img_base64 = base64.b64encode(buffer.getvalue()).decode('utf-8')
    
    # Render the result template with the barcode image and the user-provided name
    return render_template('result.html', image=img_base64, name=user_name)

