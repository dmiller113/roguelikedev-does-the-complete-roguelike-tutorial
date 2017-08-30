let ROT = require('rot-js');
let CONST = require('./constants')

console.log(CONST)

window.onload = (event) => {
  let lastBuffer = "";

  let display = new ROT.Display({
    width: CONST.DISPLAY_WIDTH, height: CONST.DISPLAY_HEIGHT, fontSize: parseInt(CONST.FONT_SIZE)
  });
  display.getContainer().getContext("2d").font = CONST.FONT_SIZE + " " + CONST.FONT_FAMILY;
  let app = Elm.CharonGame.fullscreen({initialSeed: Date.now()})

  app.ports.render.subscribe( (data) => {
    if (lastBuffer == data) return;
    lastBuffer = data;
    display.clear();
    display.drawText(0, 0, data, CONST.DISPLAY_WIDTH);
  });

  let fovData = {}
  let fovInputCallback = (x, y) => {
    return fovData[x.toString() + ":" + y.toString()] || false;
  }

  let fovOutputCallback = (x, y) => {
    app.ports.getFov.send([x, y]);
  }

  let fov = new ROT.FOV.PreciseShadowcasting(fovInputCallback);

  app.ports.createFov.subscribe( (jsonString) => {
      fovData = JSON.parse(jsonString);
  });

  app.ports.computeFov.subscribe( (info) => {
    fov.compute(info.x, info.y, info.r, fovOutputCallback);
  });

  document.body.append(display.getContainer())
}
