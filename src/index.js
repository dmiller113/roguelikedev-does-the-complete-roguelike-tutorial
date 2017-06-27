let ROT = require('rot-js');
let CONST = require('./constants')

console.log(CONST)

window.onload = (event) => {
  let display = new ROT.Display({width: CONST.DISPLAY_WIDTH, height: CONST.DISPLAY_HEIGHT})
  let app = Elm.CharonGame.fullscreen()

  app.ports.render.subscribe( (data) => {
    display.clear();
    display.draw(data[0].x, data[0].y, data[1], "#77ddFF");
  });

  document.body.append(display.getContainer())
}
