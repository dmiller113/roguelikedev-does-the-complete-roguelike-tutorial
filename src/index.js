let ROT = require('rot-js');
let CONST = require('./constants')

console.log(CONST)

window.onload = (event) => {
  let display = new ROT.Display({
    width: CONST.DISPLAY_WIDTH, height: CONST.DISPLAY_HEIGHT, fontSize: 18
  });
  display.getContainer().getContext("2d").font = "18px Overpass Mono";
  let app = Elm.CharonGame.fullscreen()

  app.ports.render.subscribe( (data) => {
    display.clear();
    display.drawText(0, 0, data, CONST.DISPLAY_WIDTH);
  });

  document.body.append(display.getContainer())
}
