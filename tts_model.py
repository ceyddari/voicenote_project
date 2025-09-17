from TTS.api import TTS

tts = TTS(model_name="tts_models/en/ljspeech/tacotron2-DDC", progress_bar=False, gpu=False)

def synthesize_text(text):
    output_path = "tts_output.wav"
    tts.tts_to_file(text=text, file_path=output_path)
    return output_path
