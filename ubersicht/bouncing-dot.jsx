// bouncing-dot.jsx
// Version 1.8 - Multiple balls with time-based movement

import { React, useState, useEffect } from 'uebersicht'

// Initial state for multiple dots
export const initialState = {
  dots: [
    {
      x: 100,
      y: 100,
      directionX: 1,
      directionY: 1,
      color: 'red',
    },
    {
      x: window.innerWidth - 100,
      y: 100,
      directionX: -1,
      directionY: 1,
      color: 'rgb(0, 255, 100)',  // bright green
    },
    {
      x: window.innerWidth / 2,
      y: window.innerHeight - 100,
      directionX: 1,
      directionY: -1,
      color: 'rgb(50, 150, 255)',  // bright blue
    }
  ],
  speed: 100,    // Pixels per second
  radius: 7,     // Reduced from 10
  lastUpdate: Date.now()
}

// Style for the widget
export const className = `
  width: 100%;
  height: 100%;
  background-color: transparent;
  position: absolute;
  top: 0;
  left: 0;
  z-index: 2147483647;
`

// Update state function
export const updateState = (event, previousState) => {
  const currentTime = Date.now();
  const deltaTime = (currentTime - previousState.lastUpdate) / 1000;
  const { speed, radius } = previousState;
  
  // Update each dot
  const updatedDots = previousState.dots.map(dot => {
    let { x, y, directionX, directionY, color } = dot;
    
    // Calculate movement based on actual elapsed time
    const distance = speed * deltaTime;
    x += distance * directionX;
    y += distance * directionY;
    
    // Bounce off edges
    if (x <= radius) {
      x = radius;
      directionX = 1;
    } else if (x >= window.innerWidth - radius) {
      x = window.innerWidth - radius;
      directionX = -1;
    }
    
    if (y <= radius) {
      y = radius;
      directionY = 1;
    } else if (y >= window.innerHeight - radius) {
      y = window.innerHeight - radius;
      directionY = -1;
    }
    
    return { x, y, directionX, directionY, color };
  });
  
  return {
    ...previousState,
    dots: updatedDots,
    lastUpdate: currentTime
  };
}

// Command function
export const command = (dispatch) => {
  const animate = () => {
    dispatch({ type: 'MOVE_DOTS' });
    requestAnimationFrame(animate);
  };
  requestAnimationFrame(animate);
}

// Render function
export const render = ({ dots, radius }) => {
  return (
    <div>
      {dots.map((dot, index) => (
        <div
          key={index}
          style={{
            position: 'absolute',
            left: Math.round(dot.x - radius),
            top: Math.round(dot.y - radius),
            width: radius * 2,
            height: radius * 2,
            borderRadius: '50%',
            backgroundColor: dot.color,
            transform: 'translate3d(0,0,0)'
          }}
        />
      ))}
    </div>
  );
}
