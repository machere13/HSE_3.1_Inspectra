(function() {
  window.ConnectionManager = {
    isNodeVisible: function(node) {
      return node.element.style.display !== 'none' && 
             node.element.offsetParent !== null;
    },

    getVisibleNodes: function(nodes) {
      return nodes.filter(this.isNodeVisible.bind(this));
    },

    adjustCornerForBorderRadius: function(corner, node, borderRadius) {
      const centerX = node.x;
      const centerY = node.y;
      
      const dx = centerX - corner.x;
      const dy = centerY - corner.y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      
      if (dist === 0) return corner;
      
      const dirX = dx / dist;
      const dirY = dy / dist;
      
      return {
        x: corner.x + dirX * borderRadius,
        y: corner.y + dirY * borderRadius
      };
    },

    getNearestCorners: function(node1, node2) {
      const borderRadius = 8;
      
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

      const adjustedCorner1 = this.adjustCornerForBorderRadius(nearestCorner1, node1, borderRadius);
      const adjustedCorner2 = this.adjustCornerForBorderRadius(nearestCorner2, node2, borderRadius);

      return { from: adjustedCorner1, to: adjustedCorner2 };
    },

    areFiltersActive: function(nodes) {
      const totalNodes = nodes.length;
      const visibleNodes = this.getVisibleNodes(nodes);
      return visibleNodes.length < totalNodes && visibleNodes.length > 0;
    },

    hasConnectionBetween: function(connections, n1, n2) {
      for (let i = 0; i < connections.length; i++) {
        const c = connections[i];
        if ((c.from === n1 && c.to === n2) || (c.from === n2 && c.to === n1)) return true;
      }
      return false;
    },

    ensureEachNodeHasConnection: function(visibleNodes, connections) {
      if (visibleNodes.length < 2) return;

      const degree = function(node) {
        let d = 0;
        for (let i = 0; i < connections.length; i++) {
          const c = connections[i];
          if (c.from === node) d++;
          if (c.to === node) d++;
        }
        return d;
      };

      visibleNodes.forEach((node) => {
        if (degree(node) > 0) return;
        let best = null;
        let bestD = Infinity;
        for (let i = 0; i < visibleNodes.length; i++) {
          const other = visibleNodes[i];
          if (other === node) continue;
          const dx = other.x - node.x;
          const dy = other.y - node.y;
          const dist = Math.sqrt(dx * dx + dy * dy);
          if (dist < bestD) {
            bestD = dist;
            best = other;
          }
        }
        if (best && !this.hasConnectionBetween(connections, node, best)) {
          connections.push({ from: node, to: best });
        }
      });
    },

    calculateConnections: function(nodes, canvasWidth, canvasHeight) {
      const visibleNodes = this.getVisibleNodes(nodes);
      if (visibleNodes.length === 0) return [];

      const connections = [];
      
      const filtersActive = this.areFiltersActive(nodes);
      const maxDistanceMultiplier = filtersActive ? 2.0 : 0.4;
      const maxDistance = Math.min(canvasWidth, canvasHeight) * maxDistanceMultiplier;

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

      this.ensureEachNodeHasConnection(visibleNodes, connections);
      return connections;
    }
  };
})();

