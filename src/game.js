import ROT from "rot-js"

console.log(ROT.isSupported());
console.log("aset");
let display = new ROT.Display({width: 80, height: 24});
document.body.append(display.getContainer());
display.draw(5,  4, "@");
display.draw(15, 4, "%", "#0f0");          /* foreground color */
display.draw(25, 4, "#", "#f00", "#009");  /* and background color */
