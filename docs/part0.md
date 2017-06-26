# Part 0, JS
So starting this project, I decided to use a stack of **Babel.js**, **EMCA 6~7**, **Rot.js** and **Gulp**. That stack alone however, led to issues with the fact that **Babel** does not come with the code needed to implement `require` statements in browser, necessitating an addition part to add that in.
##### Browserify
My first attempt to resolve this was with the gulp plugin for Browserify and its babel plugin. For projects willing to compile to an intermediate file before a final compilation, this solution would have worked quite well, but, I was stubborn (it doesn't help I was doing this at midnight) and wanted to keep it all in node's/gulp's streams and not have any odd intermediate files floating around. I deleted all things related to Browserify, and looked at the next solution suggested on **Stack Overflow**.
##### Rollup
The second technology I tried was a EMCA 6~7 compliant bundler called Rollup. However with finding only poor documentation (likely an issue of my tiredness over their ecosystem) and still trying to interface everything through **Gulp**, I was having almost no luck getting it to provide the correct outputs that the rest of **Gulp** was expecting.
##### Webpack
The last, and most successful solution I tried was a plain webpack bundling. Note that at this point, I didn't have any webpack config and was using `./node_modules/bin/webpack` for all my webpack needs. After this bundled and ran on a browser, I started work on getting an `@` on screen with **Rot.js** and called it a night after finishing.

# Part 0, Thinking
The next few days, I was caught up thinking about an old desire of mine, to see a roguelike programmed in a functional language. My current functional language of choice is even web ready: **Elm**. After a few days of thinking, I was stuck after work for a few hours, so I made a branch and set to work. Back to step 0.

# Part 0, Elm
So first things first. Remove all traces of webpack, babel, **everything**. One `rm` and a pruning of my `package.json` later, we were back at square one.

I figured with Elm as the main compiler, I could just go with a vanilla `<script>` tag for getting **Rot.js** in scope, but as I had installed the node version, it really was expecting node processing before being ready for code. So **webpack** returned. Then it was a matter of looking up how interop with vanilla JS worked in Elm.

After a brief search, I found that I was going to need to use Elm Ports: essentially event driven messages between normal JS and Elm based code. So I made a quick output port to render a string to the Rot display, and started testing it out. After a few false starts, I had a `@` on screen. Success! As I had a bit of time and wanting a preview of how handling game state with Elm was going to be, I started work on getting a moving `@` on screen.

With that, I ran into a few snags, though mostly issues that _may_ cause problems rather than issues that _will_ cause problems. Elm's core keyboard handling is rather, _basic_ is the nicest word, though the community has a few packages that should help out with _advanced_ features like multiple keypresses, and capital letters. But after a bit of work, we had a moving `@` and a very basic representation of gamestate modeled.

# Goals for this Project
The main goal for this project is an actual released game. My plan is to revisit the game that I originally was making with this tutorial series: **Fires of Charon**, a game lost to the ravages of time and MegaUpload. Fortunately, it was not much beyond what the tutorial had at the time: a single floor which saved and loaded, 2 monsters, equipment with my own implementation of mechanics as the equipment section of the tutorial had not come out yet, and a basic dungeon generation algorithm.

The basic story for the game is that the player has been thrown into the **Well of Sacrifice** under which lives the **Caves of Charon**, a forgotten and seldom visited place connected to many deep and lost portions of the world. Its populous is as varied, as it is horrible, with many of its residents having been seldom viewed by Man, being known only by story and song, fearfully whispered by dim campfires and hearths.

Lying broken and dying on the floor of the well, the player is presented with a choice by the **Shade of Koranth**, who has been trapped in the caves by magics of old. The shade gives the player the choice of dying then and there, or being possessed; of healing to more than past strength and hew or of dying forgotten on this dusty floor. The price of such resurection would of course be small: only that the player provide food for it, and be carried out of this forsaken cave. Of course, what a Shade eats is souls... and yours is as tastey as any dungeon resident.

##### Mechanics
Actual gameplay-wise, the goals are:
* A simple to understand, 20~60 minute roguelike, that provides both tactical and strategic challenge, though focusing more on tactics.
* Interclass balance is unimportant, though meaningful choices in each class is a paramount.
* Two main resources to juggle/maintain: Health, and Soul.
* Hunger mechanic is staved off by defeating enemies with
your Shade enchanted weapon, or consuming soul crystals.
* Health does not regen overtime without spending Soul.
* Shade has various Boons for you, all with low, low, low costs to your soul. There's even payment plans for those low on soul.
* 10 Levels, with 3 Main sections: The Well, The Temple, The Tunnels.
* Optional side areas, which replace levels of the main dungeon if their entrance is taken: The Labrynth at Coretos, The Cage of the Headless Fool, The Aerotorium, The Jungle in the Dark, The Wailing Cavern, and The Shifting Desert.
* 26 enemies: 1 for each letter of the alphabet.
* Randomly generated Unique monsters.
* 1 Boss guarding each section.
* Choice of 3 combat styles from the beginning:  
  * A melee focused system that focuses on special attacks being executed chosen from what direction the player attacks in.
  * A combo focused character, with each special attack leading to a completely new set of abilities.
  * Item based spell system, similar to the Ring of Set from Conan.
* Less focus on found weapons by providing weapon of the players choice that grows with the players time in the dungeon.
* Meaningful differences between weapon types.
* Items focusing on in combat escape being a rarity.
* Random Artifacts (Stretch)
* Rune System for armors providing set bonuses per rune.

##### Links:
[Elm Homepage](https://www.elm-lang.org)
[r/roguelikedev](https://www.reddet.com/r/roguelikedev)
[My Blog](http://inchaosproductions.blogspot.com/)
