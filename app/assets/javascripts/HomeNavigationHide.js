(function () {
  function hideNavigationGroups() {
    const isHomePage = window.location.pathname === '/' || window.location.pathname === '/pages/home';
    if (!isHomePage) return;

    const content = document.querySelector('.W_NavigationContent');
    if (!content) return;
    
    const groups = document.querySelectorAll('.W_NavigationItems[data-index="1"]');
    groups.forEach((group) => {
      group.classList.add('W_NavigationItems--Hidden');
    });

    const barItems = document.querySelectorAll('.W_NavigationBar-Item[data-index="1"]');
    barItems.forEach((item) => {
      item.classList.add('W_NavigationBar-Item--Hidden');
    });
    
  }

  document.addEventListener('DOMContentLoaded', hideNavigationGroups);
  document.addEventListener('turbo:load', hideNavigationGroups);
})();

