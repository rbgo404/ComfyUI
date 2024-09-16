import subprocess
import os
import uuid
from comfy_utils import run_comfyui_in_background, check_comfyui, load_workflow, prompt_update_workflow, send_comfyui_request, get_img_file_path, image_to_base64, stop_server_on_port, is_comfyui_running
import requests
import json

class InferlessPythonModel:
    def initialize(self):
        self.directory_path = os.getenv('NFS_VOLUME')
        if not os.path.exists(self.directory_path+"/ComfyUI"):
            subprocess.run(["wget", "https://github.com/rbgo404/ComfyUI/raw/comfy-cli/build.sh"])
            subprocess.run(["bash", "build.sh"], check=True)
          
        self._data_dir = self.directory_path+"/workflows"
        self.server_address = "127.0.0.1:8188"
        self.client_id = str(uuid.uuid4())
        
        if is_comfyui_running(self.server_address):
            stop_server_on_port(8188)    
        run_comfyui_in_background()
        self.ws = check_comfyui(self.server_address,self.client_id)

    def infer(self, inputs):
        workflow_input = inputs.get("workflow")
        prompt = inputs.get("prompt")
        negative_prompt = inputs.get("negative_prompt")
        workflow_filename = "workflow_api.json"
        workflow_path = os.path.join(self._data_dir, workflow_filename)
        # Process the workflow input
        if workflow_input.startswith('http://') or workflow_input.startswith('https://'):
            response = requests.get(workflow_input)
            workflow_json = response.json()
        else:
            workflow_json = json.loads(workflow_input)
        
        # Save the workflow JSON to a file
        with open(workflow_path, 'w') as f:
            json.dump(workflow_json, f)
        
        # Load the saved workflow
        workflow = load_workflow(workflow_path)
        prompt = prompt_update_workflow(workflow_filename, workflow, prompt)
        prompt_id = send_comfyui_request(self.ws, prompt, self.server_address, self.client_id)
        file_path = get_img_file_path(self.server_address, prompt_id)
        image_base64 = image_to_base64(self.directory_path+"/ComfyUI"+file_path)
        return {"generated_image_base64": image_base64}
    
    def finalize(self):
        pass
