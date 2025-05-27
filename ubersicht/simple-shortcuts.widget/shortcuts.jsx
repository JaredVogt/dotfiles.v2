
import { React } from 'uebersicht'
// --------------- CUSTOMIZE ME ---------------
// the following dimensions are specified in pixels
const WIDTH = 400 // width of the widget
const TOP = 10 // top margin
const LEFT = 20 // left margin
const REFRESH_FREQUENCY = 3600 // widget refresh frequency in seconds
// --------------------------------------------

// the refresh frequency in milliseconds
export const refreshFrequency = REFRESH_FREQUENCY * 1000;

// the CSS style for this widget, written using Emotion
// https://emotion.sh/
export const className = `
  top: ${TOP}px;
  left: ${LEFT}px;
  width: ${WIDTH}px;
  box-sizing: border-box;
  padding: 10px 10px 10px;
  color: #FFFFFF;
  font-family: Helvetica Neue;
  font-weight: 300;
  text-align: justify;
  line-height: 1;
  
  h1 {
    font-size: 24px;
    margin: 8px 0 8px;
  }
  
  h2 {
    font-size: 22px;
    margin: 0 0 3 0;
  }
  
  ul {
    margin: 0;
  }
  
  li {
    font-size: 18px;
    margin-bottom: 5px;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  /* Keyboard shortcut styling */
  .kbd {
    display: inline-block;
    padding: 3px 6px;
    font-family: monospace;
    font-size: 14px;
    line-height: 1;
    background-color: rgba(200, 200, 200, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 3px;
    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.2);
    color: #FFFFFF;
    font-weight: 400;
  }

  /* Style for the arrow between shortcuts and descriptions */
  .arrow {
    color: rgba(255, 255, 255, 0.6);
    margin: 0 4px;
  }
`

import shortcuts from './shortcuts'

function KeyboardShortcut({ shortcut }) {
  // Split the shortcut string into individual keys
  const keys = shortcut.split('+').map(key => key.trim());
  
  return (
    <span className="shortcut-wrapper">
      {keys.map((key, index) => (
        <>
          <span className="kbd">{key}</span>
          {index < keys.length - 1 && <span className="kbd-separator"> + </span>}
        </>
      ))}
    </span>
  );
}

function Category({ name, data }) {
  return (
    <div key={name}>
      <h2>{name}</h2>
      <ul>
        {Object.entries(data).map(([description, shortcut]) => (
          <li>
            <KeyboardShortcut shortcut={shortcut} />
            <span className="arrow">→</span>
            {description}
          </li>
        ))}
      </ul>
    </div>
  );
}

export const render = () => {
  return (
    <div>
      <h1>Shortcuts</h1>
      {Object.entries(shortcuts).map(([category, data]) => (
        <Category name={category} data={data} />
      ))}
    </div>
  );
}
