document.addEventListener("DOMContentLoaded", function () {
    var sidebar = document.getElementById("sidebar");
    var overlay = document.getElementById("sidebarOverlay");
    var toggleBtn = document.getElementById("sidebarToggle");

    function openSidebar() {
        sidebar.classList.add("sidebar-open");
        overlay.classList.add("show");
    }

    function closeSidebar() {
        sidebar.classList.remove("sidebar-open");
        overlay.classList.remove("show");
    }

    if (toggleBtn) {
        toggleBtn.addEventListener("click", function () {
            if (sidebar.classList.contains("sidebar-open")) {
                closeSidebar();
            } else {
                openSidebar();
            }
        });
    }

    if (overlay) {
        overlay.addEventListener("click", closeSidebar);
    }

    // Cierra el sidebar automáticamente al pasar a escritorio
    window.addEventListener("resize", function () {
        if (window.innerWidth > 991.98) {
            closeSidebar();
        }
    });
});
