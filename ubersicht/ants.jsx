// wandering-ants.jsx
import { React, useState, useEffect } from 'uebersicht'

export const initialState = {
  ants: [
    {
      x: 100,
      y: 100,
      velocity: { x: 1.5, y: 0 },
      rotation: 0,
      legPhase: 0,
      isEdgePaused: false,
      edgePauseTimer: 0,
      lastReverse: Date.now(),
      isPaused: false,
      pauseStartTime: 0,
      color: 'red'
    },
    {
      x: window.innerWidth - 100,
      y: 100,
      velocity: { x: -1.5, y: 0 },
      rotation: 180,
      legPhase: Math.PI,
      isEdgePaused: false,
      edgePauseTimer: 0,
      lastReverse: Date.now(),
      isPaused: false,
      pauseStartTime: 0,
      color: 'red'
    }
  ],
  lastUpdate: Date.now()
}

export const className = `
  width: 100%;
  height: 100%;
  background-color: transparent;
  position: absolute;
  top: 0;
  left: 0;
  z-index: 2147483647;
`

export const updateState = (event, previousState) => {
  const currentTime = Date.now();
  const deltaTime = (currentTime - previousState.lastUpdate) / 1000;
  
  const updatedAnts = previousState.ants.map(ant => {
    let { x, y, velocity, rotation, legPhase, isEdgePaused, edgePauseTimer, lastReverse, isPaused, pauseStartTime, color } = ant;
    
    const timeSinceLastReverse = currentTime - lastReverse;

    // Handle paused state and periodic direction changes
    if (isPaused) {
      const pauseDuration = currentTime - pauseStartTime;
      if (pauseDuration >= 3000) { // 3 second pause
        isPaused = false;
        
        // Calculate distance to each edge
        const distToLeft = x;
        const distToRight = window.innerWidth - x;
        const distToTop = y;
        const distToBottom = window.innerHeight - y;
        
        // Find closest edge and set angle to move away from it
        let targetAngle;
        if (distToLeft <= Math.min(distToRight, distToTop, distToBottom)) {
          targetAngle = 0; // Move right if closest to left edge
        } else if (distToRight <= Math.min(distToLeft, distToTop, distToBottom)) {
          targetAngle = Math.PI; // Move left if closest to right edge
        } else if (distToTop <= Math.min(distToLeft, distToRight, distToBottom)) {
          targetAngle = Math.PI / 2; // Move down if closest to top edge
        } else {
          targetAngle = -Math.PI / 2; // Move up if closest to bottom edge
        }
        
        // Add some randomness to avoid straight lines
        const randomVariation = (Math.random() - 0.5) * Math.PI / 4; // ±45 degrees
        const finalAngle = targetAngle + randomVariation;
        
        velocity = {
          x: Math.cos(finalAngle) * 3,
          y: Math.sin(finalAngle) * 3
        };
        lastReverse = currentTime;
      } else {
        // Stay paused
        velocity = { x: 0, y: 0 };
      }
    } else if (timeSinceLastReverse >= 15000) {
      // Start a new pause
      isPaused = true;
      pauseStartTime = currentTime;
      velocity = { x: 0, y: 0 };
    }

    if (!isPaused) {
        // Handle edge avoidance with no bias
        const margin = 50;
        if (x <= margin || x >= window.innerWidth - margin || 
            y <= margin || y >= window.innerHeight - margin) {
          
          // Determine exact edge and set specific escape angle
          let escapeAngle;
          if (x <= margin) escapeAngle = 0;  // Move right
          else if (x >= window.innerWidth - margin) escapeAngle = Math.PI;  // Move left
          else if (y <= margin) escapeAngle = Math.PI/2;  // Move down
          else escapeAngle = -Math.PI/2;  // Move up
          
          // Add randomness to escape angle
          const randomVariation = (Math.random() - 0.5) * Math.PI/2;  // ±45 degrees
          const finalEscapeAngle = escapeAngle + randomVariation;
          
          // Set new velocity with escape speed
          const escapeSpeed = 3;
          velocity = {
            x: Math.cos(finalEscapeAngle) * escapeSpeed,
            y: Math.sin(finalEscapeAngle) * escapeSpeed
          };
        } else {
        // Regular wandering behavior when not near edges
      if (!isPaused) {
        // Remove accumulating bias from wandering
        const currentSpeed = Math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
        const currentDirection = Math.atan2(velocity.y, velocity.x);
        
        // Add small random changes to direction instead of accumulating velocity
        const turnAmount = (Math.random() - 0.5) * 0.2; // Small random turn
        const newDirection = currentDirection + turnAmount;
        
        // Maintain consistent speed
        const targetSpeed = 1.5;
        velocity = {
          x: Math.cos(newDirection) * targetSpeed,
          y: Math.sin(newDirection) * targetSpeed
        };
        }
      }

      // Update position
      x += velocity.x * deltaTime * 60;
      y += velocity.y * deltaTime * 60;
    }
    
    // Smooth rotation update
    const targetAngle = Math.atan2(velocity.y, velocity.x) * (180 / Math.PI);
    const diff = targetAngle - rotation;
    const normalizedDiff = ((diff + 180) % 360) - 180;
    rotation += normalizedDiff * 0.1;

    // Leg animation update
    const speed = Math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
    legPhase = (legPhase + speed * 0.5) % (2 * Math.PI);

    return { 
      x, y, velocity, rotation, legPhase, isEdgePaused, 
      edgePauseTimer, lastReverse, isPaused, pauseStartTime, color 
    };
  });

  return {
    ...previousState,
    ants: updatedAnts,
    lastUpdate: currentTime
  };
}

export const command = (dispatch) => {
  try {
    console.log('Ant widget starting...');
    const animate = () => {
      try {
        dispatch({ type: 'MOVE_ANTS' });
        requestAnimationFrame(animate);
      } catch (error) {
        console.error('Animation error:', error);
      }
    };
    requestAnimationFrame(animate);
  } catch (error) {
    console.error('Command initialization error:', error);
  }
}

export const render = ({ ants }) => {
  if (!ants || ants.length === 0) {
    console.error('No ants data available for rendering');
    return <div>Widget initializing...</div>;
  }
  
  return (
    <div>
      {ants.map((ant, index) => (
        <svg
          key={index}
          style={{
            position: 'absolute',
            left: Math.round(ant.x - 5),
            top: Math.round(ant.y - 5),
            transform: `rotate(${ant.rotation}deg)`,
            transition: 'transform 0.2s ease-out'
          }}
          width="10"
          height="10"
          viewBox="0 0 10 10"
        >
          <ellipse cx="5" cy="5" rx="2.5" ry="1.5" fill={ant.color} />
          <path 
            d={`M 3 4 Q 1 ${2 + Math.sin(ant.legPhase) * 1} 0 ${3 + Math.sin(ant.legPhase) * 0.5}`} 
            stroke={ant.color} 
            fill="none" 
            strokeWidth="0.5" 
          />
          <path 
            d={`M 3 6 Q 1 ${8 + Math.sin(ant.legPhase + Math.PI) * 1} 0 ${7 + Math.sin(ant.legPhase + Math.PI) * 0.5}`} 
            stroke={ant.color} 
            fill="none" 
            strokeWidth="0.5" 
          />
          <path 
            d={`M 7 4 Q 9 ${2 + Math.sin(ant.legPhase + Math.PI) * 1} 10 ${3 + Math.sin(ant.legPhase + Math.PI) * 0.5}`} 
            stroke={ant.color} 
            fill="none" 
            strokeWidth="0.5" 
          />
          <path 
            d={`M 7 6 Q 9 ${8 + Math.sin(ant.legPhase) * 1} 10 ${7 + Math.sin(ant.legPhase) * 0.5}`} 
            stroke={ant.color} 
            fill="none" 
            strokeWidth="0.5" 
          />
          <path d="M 6.5 4 Q 8 2 7.5 1" stroke={ant.color} fill="none" strokeWidth="0.5" />
          <path d="M 6.5 4 Q 9 3 8.5 2" stroke={ant.color} fill="none" strokeWidth="0.5" />
        </svg>
      ))}
    </div>
  );
}
