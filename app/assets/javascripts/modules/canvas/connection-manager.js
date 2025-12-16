(function() {
  window.ConnectionManager = {
    isNodeVisible: function(node) {
      return node.element.style.display !== 'none' && 
             node.element.offsetParent !== null;
    },

    getVisibleNodes: function(nodes) {
      return nodes.filter(this.isNodeVisible.bind(this));
    },

    getNearestCorners: function(node1, node2) {
      const corners1 = [
        { x: node1.x - node1.width / 2, y: node1.y - node1.height / 2 },
        { x: node1.x + node1.width / 2, y: node1.y - node1.height / 2 },
        { x: node1.x - node1.width / 2, y: node1.y + node1.height / 2 },
        { x: node1.x + node1.width / 2, y: node1.y + node1.height / 2 }
      ];

      const corners2 = [
        { x: node2.x - node2.width / 2, y: node2.y - node2.height / 2 },
        { x: node2.x + node2.width / 2, y: node2.y - node2.height / 2 },
        { x: node2.x - node2.width / 2, y: node2.y + node2.height / 2 },
        { x: node2.x + node2.width / 2, y: node2.y + node2.height / 2 }
      ];

      let minDistance = Infinity;
      let nearestCorner1 = null;
      let nearestCorner2 = null;

      corners1.forEach(corner1 => {
        corners2.forEach(corner2 => {
          const dx = corner2.x - corner1.x;
          const dy = corner2.y - corner1.y;
          const distance = Math.sqrt(dx * dx + dy * dy);

          if (distance < minDistance) {
            minDistance = distance;
            nearestCorner1 = corner1;
            nearestCorner2 = corner2;
          }
        });
      });

      return { from: nearestCorner1, to: nearestCorner2 };
    },

    calculateConnections: function(nodes, canvasWidth, canvasHeight) {
      const visibleNodes = this.getVisibleNodes(nodes);
      if (visibleNodes.length === 0) return [];

      const connections = [];
      const maxDistance = Math.min(canvasWidth, canvasHeight) * 0.4;

      for (let i = 0; i < visibleNodes.length; i++) {
        for (let j = i + 1; j < visibleNodes.length; j++) {
          const node1 = visibleNodes[i];
          const node2 = visibleNodes[j];

          const dx = node2.x - node1.x;
          const dy = node2.y - node1.y;
          const distance = Math.sqrt(dx * dx + dy * dy);

          if (distance <= maxDistance) {
            connections.push({ from: node1, to: node2 });
          }
        }
      }

      return connections;
    }
  };
})();

