(function() {
  window.CanvasRenderer = {
    drawLines: function(ctx, canvasWidth, canvasHeight, connections, connectionManager) {
      ctx.clearRect(0, 0, canvasWidth, canvasHeight);
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
      ctx.lineWidth = 1;

      connections.forEach(conn => {
        if (!connectionManager.isNodeVisible(conn.from) || 
            !connectionManager.isNodeVisible(conn.to)) return;

        const corners = connectionManager.getNearestCorners(conn.from, conn.to);

        ctx.beginPath();
        ctx.moveTo(corners.from.x, corners.from.y);
        ctx.lineTo(corners.to.x, corners.to.y);
        ctx.stroke();
      });
    }
  };
})();

