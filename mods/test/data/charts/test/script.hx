function createPost() {
    this.camHUD.alpha = 0;
}

function stepHit(curStep) {
    switch (curStep){
        case 632:
            this.defaultCamZoom += 0.2;
        case 636:
            this.defaultCamZoom += 0.4;
        case 640:
            this.defaultCamZoom -= 0.6;
    }
}

function beatHit(curBeat) {
    if (curBeat == 32){
        FlxTween.tween(this.camHUD, {alpha: 1}, 1, {ease: FlxEase.linear});
    }

    if (Config.camZooms && curBeat > 96 && curBeat <= 112){
        FlxG.camera.zoom += 0.020;
        this.camHUD.zoom += 0.01;
    }

    switch (curBeat){
        case 64:
            this.camHUD.flash(0xffffffff, 1);
        case 72:
            this.camHUD.flash(0xffffffff, 1);
        case 112, 114, 116:
            this.defaultCamZoom += 0.2;
        case 119:
            this.defaultCamZoom -= 0.6;
        case 120, 122, 124:
            this.defaultCamZoom += 0.2;
        case 127:
            this.defaultCamZoom -= 0.6;
    }

	this.dad.dance();
}
