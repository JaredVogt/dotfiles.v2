
// Command to read the readme file
export const command = "cat ~/projects/readme.md"

// Refresh every 10 seconds (10000 milliseconds)
export const refreshFrequency = 10000;

// Same CSS but moved to bottom 10%
export const className =`
  bottom: 10%;
  left: 3%;
  width: 340px;
  box-sizing: border-box;
  padding: 20px;
  background-color: rgba(255, 255, 255, 0.9);
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
  max-height: 400px;
  overflow-y: auto;
`

// Render the readme content
export const render = ({output}) => {
  // Split the content into lines for better formatting
  const lines = output.split('\n')
  const title = lines[0] // Assume first line is title
  const content = lines.slice(1).join('\n') // Rest is content

  return (
    <div>
      <h1>{title}</h1>
      <div style={{whiteSpace: 'pre-wrap'}}>
        {content}
      </div>
    </div>
  );
}
