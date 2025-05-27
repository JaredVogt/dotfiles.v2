// Version 1.1
// Full height image display widget, centered horizontally

// Command to copy image to widget directory
export const command = "cp ~/Downloads/IMG_0462.jpeg $PWD/current-image.jpeg"

// Run once since we're just copying the file
export const refreshFrequency = false;

// Styling for centered, full-height container
export const className = `
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  box-sizing: border-box;
  padding: 10px;
  
  img {
    height: 100vh;
    width: auto;
    max-width: 100vw;
    object-fit: contain;
    border-radius: 8px;
  }
`

// Render the image
export const render = () => {
  return (
    <div>
      <img 
        src="current-image.jpeg"
        alt="Full height display"
      />
    </div>
  );
}
