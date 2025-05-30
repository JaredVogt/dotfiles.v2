// This is a simple example Widget to get you started with Übersicht.
// For the full documentation please visit:
// https://github.com/felixhageloh/uebersicht

// Version tracking
export const version = "1.0.0";  // Initial version with screen targeting

// the refresh frequency in milliseconds
export const refreshFrequency = 1000000;

// the CSS style for this widget, written using Emotion
// https://emotion.sh/
export const className = `
  top: 10%;
  left: 3%;
  width: 340px;
  box-sizing: border-box;
  padding: 120px 20px 20px;
  background-color: rgba(255, 255, 255, 0.9);
  background-image: url('logo.png');
  background-repeat: no-repeat;
  background-size: 176px 84px;
  background-position: 50% 20px;
  -webkit-backdrop-filter: blur(20px);
  color: #141f33;
  font-family: Helvetica Neue;
  font-weight: 300;
  border: 2px solid #fff;
  border-radius: 1px;
  text-align: justify;
  line-height: 1.5;

  h1 {
    font-size: 20px;
    margin: 16px 0 8px;
  }

  em {
    font-weight: 400;
    font-style: normal;
  }
`

// render gets called after the shell command has executed. The command's output
// is passed in as a string.
export const render = () => {
  return (
    <div>
      <h1>Welcome!</h1>
      <p>
        Thanks for trying out Übersicht!
        This is an example widget to get you started.
      </p>
      <p>
        To view this example widget, choose <em>'Open Widgets Folder'</em>{' '}
        from the status bar menu. Use it to create your own widget,
        or simply delete it.
      </p>
      <p>
        To download other widgets, choose <em>'Visit Widgets Gallery'</em>{' '}
        from the status bar menu.
      </p>
    </div>
  );
}
