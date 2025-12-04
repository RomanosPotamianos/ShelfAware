<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*" %>
<%@ page import="java.sql.*" %>
<%
    // Session check - Redirect if not logged in
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userName = (String) session.getAttribute("userName");
%>
<!DOCTYPE html>
<html lang="el">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications - ShelfAware</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --beige: #f5efe6;
            --nav-bg: #ffffff;
            --accent: #7ac48a;
            --accent-dark: #5da76f;
            --muted: #6b7280;
            --card: #ffffff;
            --shadow: 0 6px 18px rgba(16, 24, 40, 0.08);
            --danger: #dc2626;
            --warning: #ff9100;
            --info: #74c0fc;
            --success: #51cf66;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(180deg, var(--beige) 0%, #fbf8f4 100%);
            min-height: 100vh;
            color: #0f172a;
            padding: 28px;
        }

        /* Navigation */
        .topnav {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--nav-bg);
            padding: 14px 20px;
            border-radius: 12px;
            box-shadow: var(--shadow);
            max-width: 1200px;
            margin: 0 auto 22px;
            position: sticky;
            top: 18px;
            z-index: 10;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 600;
            font-size: 18px;
        }

        .brand .logo {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            display: inline-grid;
            place-items: center;
            background: linear-gradient(135deg, #ffd6a5, #ffb4a2);
            color: #1f2937;
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }

        .navlinks {
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .nav-btn {
            padding: 8px 14px;
            border-radius: 10px;
            background: transparent;
            border: 0;
            cursor: pointer;
            font-weight: 600;
            color: var(--muted);
            transition: all 0.18s ease;
            text-decoration: none;
        }

        .nav-btn:hover {
            transform: translateY(-2px);
            color: #111827;
        }

        .nav-btn.active {
            background: linear-gradient(180deg, #fff 0%, #f3f6ff 100%);
            box-shadow: 0 8px 24px rgba(16, 24, 40, 0.08);
            color: #0f172a;
            border: 1px solid rgba(15, 23, 42, 0.06);
        }

        .user-section {
            display: flex;
            align-items: center;
            gap: 12px;
            padding-left: 12px;
            border-left: 1px solid #e5e7eb;
        }

        .user-name {
            font-weight: 500;
            color: #0f172a;
            font-size: 14px;
        }

        .logout-btn {
            padding: 8px 14px;
            border-radius: 8px;
            background: var(--danger);
            color: white;
            border: 0;
            cursor: pointer;
            font-weight: 600;
            font-size: 12px;
            transition: all 0.18s ease;
        }

        .logout-btn:hover {
            transform: translateY(-2px);
            background: #b91c1c;
        }

        /* Main Container */
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .panel {
            background: var(--card);
            border-radius: 12px;
            padding: 28px;
            box-shadow: var(--shadow);
        }

        .panel h2 {
            margin: 0 0 8px 0;
            font-size: 20px;
            color: #0f172a;
        }

        .panel-description {
            color: var(--muted);
            font-size: 13px;
            margin: 0 0 24px 0;
        }

        /* Statistics */
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: linear-gradient(135deg, var(--accent) 0%, var(--accent-dark) 100%);
            color: white;
            padding: 20px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(122, 196, 138, 0.2);
        }

        .stat-card.critical {
            background: linear-gradient(135deg, var(--warning) 0%, var(--danger) 100%);
            box-shadow: 0 4px 12px rgba(220, 38, 38, 0.2);
        }

        .stat-card.unread {
            background: linear-gradient(135deg, var(--info) 0%, #0ea5e9 100%);
            box-shadow: 0 4px 12px rgba(116, 192, 252, 0.2);
        }

        .stat-card h4 {
            font-size: 28px;
            margin: 0 0 4px 0;
            font-weight: 700;
        }

        .stat-card p {
            font-size: 12px;
            opacity: 0.95;
            margin: 0;
        }

        /* Filters */
        .filter-section {
            display: flex;
            gap: 12px;
            margin-bottom: 24px;
            flex-wrap: wrap;
            align-items: center;
        }

        .btn {
            padding: 10px 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.18s ease;
            font-family: 'Inter', system-ui;
        }

        .btn-filter {
            background: #f3f4f6;
            color: #374151;
            border: 1px solid #e5e7eb;
        }

        .btn-filter.active {
            background: var(--accent);
            color: white;
            border-color: var(--accent);
            box-shadow: 0 4px 12px rgba(122, 196, 138, 0.2);
        }

        .btn-filter:hover {
            background: #e5e7eb;
        }

        .btn-filter.active:hover {
            background: var(--accent-dark);
        }

        .btn-action {
            background: var(--accent);
            color: white;
            padding: 8px 12px;
            font-size: 12px;
        }

        .btn-action:hover {
            background: var(--accent-dark);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(122, 196, 138, 0.2);
        }

        .btn-delete {
            background: var(--danger);
            color: white;
        }

        .btn-delete:hover {
            background: #b91c1c;
        }

        /* Notifications List */
        .notification-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .notification-item {
            background: #f9fafb;
            border-left: 4px solid var(--accent);
            padding: 16px;
            border-radius: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.18s ease;
            position: relative;
            border: 1px solid #e5e7eb;
        }

        .notification-item:hover {
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
            transform: translateY(-2px);
        }

        .notification-item.unread {
            background: #fef3c7;
            border-left-color: var(--warning);
            font-weight: 500;
        }

        .notification-item.warning {
            border-left-color: var(--warning);
        }

        .notification-item.critical {
            border-left-color: var(--danger);
            background: #fef2f2;
        }

        .notification-item.success {
            border-left-color: var(--success);
        }

        .notification-content {
            flex: 1;
        }

        .notification-header {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-bottom: 8px;
        }

        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .badge-warning {
            background: var(--warning);
            color: white;
        }

        .badge-critical {
            background: var(--danger);
            color: white;
        }

        .badge-success {
            background: var(--success);
            color: white;
        }

        .badge-info {
            background: var(--info);
            color: white;
        }

        .notification-title {
            font-size: 15px;
            color: #0f172a;
            margin: 0;
            font-weight: 600;
        }

        .notification-message {
            font-size: 13px;
            color: #6b7280;
            margin: 6px 0 0 0;
            line-height: 1.5;
        }

        .notification-meta {
            display: flex;
            gap: 16px;
            margin-top: 8px;
            font-size: 12px;
            color: #9ca3af;
            flex-wrap: wrap;
        }

        .notification-meta span {
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .notification-actions {
            display: flex;
            gap: 8px;
            margin-left: 16px;
            flex-shrink: 0;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #9ca3af;
        }

        .empty-state-icon {
            font-size: 56px;
            margin-bottom: 16px;
            opacity: 0.4;
        }

        .empty-state h3 {
            color: #374151;
            margin-bottom: 8px;
            font-size: 18px;
        }

        /* Message */
        .message {
            padding: 12px 16px;
            border-radius: 8px;
            margin: 16px 0;
            font-weight: 600;
            text-align: center;
            animation: slideDown 0.3s ease-in;
            font-size: 13px;
            display: none;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .message.success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }

        .message.error {
            background: #fee2e2;
            color: #7f1d1d;
            border: 1px solid #fca5a5;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .topnav {
                flex-direction: column;
                gap: 12px;
            }

            .navlinks {
                order: -1;
                width: 100%;
                justify-content: center;
            }

            .brand {
                width: 100%;
                justify-content: center;
            }

            .user-section {
                border-left: none;
                border-top: 1px solid #e5e7eb;
                width: 100%;
                justify-content: center;
                padding: 12px 0 0 0;
            }

            .panel {
                padding: 16px;
            }

            .filter-section {
                flex-direction: column;
            }

            .btn-filter {
                width: 100%;
            }

            .notification-item {
                flex-direction: column;
                align-items: flex-start;
            }

            .notification-actions {
                margin-left: 0;
                margin-top: 12px;
                width: 100%;
            }

            .btn-action, .btn-delete {
                flex: 1;
            }

            .stats {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="topnav">
        <div class="brand">
            <div class="logo">S</div>
            ShelfAware
        </div>
        <div class="navlinks">
            <a href="pantry.jsp" class="nav-btn">Pantry</a>
            <a href="supermarketlist.jsp" class="nav-btn">Supermarket List</a>
            <a href="handleproduct.jsp" class="nav-btn">Handle Product</a>
            <a href="notifications.jsp" class="nav-btn active">🔔 Notifications</a>
        </div>
        <div class="user-section">
            <span class="user-name">Welcome, <%= userName != null ? userName : "User" %>!</span>
            <form method="post" action="logout.jsp" style="display:inline;">
                <button type="submit" class="logout-btn">Logout</button>
            </form>
        </div>
    </nav>

    <!-- Main Container -->
    <main class="container">
        <section class="panel">
            <h2>🔔 Notifications</h2>
            <p class="panel-description">Manage your notifications - expiry dates, low stock, and more</p>

            <!-- Statistics -->
            <div class="stats">
                <div class="stat-card">
                    <h4 id="total-count">0</h4>
                    <p>Total Notifications</p>
                </div>
                <div class="stat-card unread">
                    <h4 id="unread-count">0</h4>
                    <p>Unread</p>
                </div>
            </div>

            <!-- Message -->
            <div id="message" class="message"></div>

            <!-- Filters -->
            <div class="filter-section">
                <button class="btn btn-filter active" onclick="filterNotifications('all')">All</button>
                <button class="btn btn-filter" onclick="filterNotifications('unread')">Unread</button>
                <button class="btn btn-action" onclick="markAllAsRead()">✓ Mark All as Read</button>
            </div>

            <!-- Notifications List -->
            <div id="notificationContainer" class="notification-list">
                <!-- Will be populated by JavaScript/JSP -->
            </div>
        </section>
    </main>

    <script>
        // Notifications data - loaded from JSP server
        const notificationsData = [
            <%
                // TODO: Replace with database query using servlet/DAO
                // Example:
                // SELECT n.*, p.productName FROM Notification n JOIN Product p ON n.productId = p.productId 
                // WHERE n.userId = ? ORDER BY n.notificationDate DESC
                
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                
                // Mock data - Will be replaced with database data
                String[][] mockData = {
                    {"1", "101", "Milk", "Product expires in 2 days", "success", String.valueOf(System.currentTimeMillis() - 1*60*60*1000), "0"},
                    {"2", "102", "Bread", "Low stock - only 1 unit available", "info", String.valueOf(System.currentTimeMillis() - 2*60*60*1000), "0"},
                    {"3", "103", "Orange Juice", "Product has expired and should be removed", "success", String.valueOf(System.currentTimeMillis() - 4*60*60*1000), "1"},
                    {"4", "104", "Feta Cheese", "Expires in 5 days", "info", String.valueOf(System.currentTimeMillis() - 1*24*60*60*1000), "1"},
                    {"5", "105", "Eggs", "Successfully added to Pantry", "success", String.valueOf(System.currentTimeMillis() - 2*24*60*60*1000), "1"}
                };
                
                for (int i = 0; i < mockData.length; i++) {
                    String[] data = mockData[i];
            %>
            {
                id: <%= data[0] %>,
                productId: <%= data[1] %>,
                productName: "<%= data[2] %>",
                message: "<%= data[3] %>",
                type: "<%= data[4] %>",
                notificationDate: new Date(<%= data[5] %>),
                isRead: <%= data[6].equals("1") ? "true" : "false" %>
            }<%if (i < mockData.length - 1) {%>,<%}%>
            <%
                }
            %>
        ];

        let currentFilter = 'all';

        function formatDate(date) {
            const now = new Date();
            const diffMs = now - date;
            const diffMins = Math.floor(diffMs / 60000);
            const diffHours = Math.floor(diffMs / 3600000);
            const diffDays = Math.floor(diffMs / 86400000);

            if (diffMins < 1) return 'Just now';
            if (diffMins < 60) return `${diffMins} min ago`;
            if (diffHours < 24) return `${diffHours} hrs ago`;
            if (diffDays < 7) return `${diffDays} days ago`;
            
            return date.toLocaleDateString('en-US');
        }

        function getTypeInfo(type) {
            const types = {
                success: { badge: 'badge-success', label: 'Success' },
                info: { badge: 'badge-info', label: 'Info' }
            };
            return types[type] || types.info;
        }

        function renderNotifications() {
            const container = document.getElementById('notificationContainer');
            let filtered = notificationsData;

            if (currentFilter === 'unread') {
                filtered = notificationsData.filter(n => !n.isRead);
            }

            if (filtered.length === 0) {
                container.innerHTML = `
                    <div class="empty-state">
                        <div class="empty-state-icon">📭</div>
                        <h3>No Notifications</h3>
                        <p>You're all caught up - no notifications to display</p>
                    </div>
                `;
                return;
            }

            container.innerHTML = filtered.map(notification => {
                const typeInfo = getTypeInfo(notification.type);
                return `
                    <div class="notification-item ${notification.isRead ? '' : 'unread'} ${notification.type}">
                        <div class="notification-content">
                            <div class="notification-header">
                                <span class="badge ${typeInfo.badge}">${typeInfo.label}</span>
                                <h3 class="notification-title">${notification.productName}</h3>
                            </div>
                            <p class="notification-message">${notification.message}</p>
                            <div class="notification-meta">
                                <span>🕐 ${formatDate(notification.notificationDate)}</span>
                                <span>📦 ID: ${notification.productId}</span>
                            </div>
                        </div>
                        <div class="notification-actions">
                            ${!notification.isRead ? `<button class="btn btn-action" onclick="markAsRead(${notification.id})">Διάβασε</button>` : ''}
                            <button class="btn btn-delete" onclick="deleteNotification(${notification.id})">Διαγραφή</button>
                        </div>
                    </div>
                `;
            }).join('');
        }

        function updateStats() {
            const total = notificationsData.length;
            const unread = notificationsData.filter(n => !n.isRead).length;
            const critical = notificationsData.filter(n => n.type === 'critical').length;

            document.getElementById('total-count').textContent = total;
            document.getElementById('unread-count').textContent = unread;
            document.getElementById('critical-count').textContent = critical;
        }

        function filterNotifications(filter) {
            currentFilter = filter;
            document.querySelectorAll('.btn-filter').forEach(btn => {
                btn.classList.remove('active');
            });
            event.target.classList.add('active');
            renderNotifications();
            updateStats();
        }

        function markAsRead(id) {
            const notification = notificationsData.find(n => n.id === id);
            if (notification) {
                notification.isRead = true;
                renderNotifications();
                updateStats();
                
                // AJAX request to server
                fetch('NotificationServlet?action=markAsRead&notificationId=' + id, {
                    method: 'GET'
                }).catch(err => console.log('Server update pending'));
            }
        }

        function markAllAsRead() {
            notificationsData.forEach(n => {
                if (!n.isRead) n.isRead = true;
            });
            renderNotifications();
            updateStats();            // AJAX request to server
            fetch('NotificationServlet?action=markAllAsRead&userId=<%= userId %>', {
                method: 'GET'
            }).catch(err => console.log('Server update pending'));
        }

        function deleteNotification(id) {
            if (confirm('Are you sure you want to delete this notification?')) {
                const index = notificationsData.findIndex(n => n.id === id);
                if (index > -1) {
                    notificationsData.splice(index, 1);
                    renderNotifications();
                    updateStats();
                    showMessage('Notification deleted', 'success');
                    
                    // AJAX request to server
                    fetch('NotificationServlet?action=deleteNotification&notificationId=' + id, {
                        method: 'GET'
                    }).catch(err => console.log('Server update pending'));
                }
            }
        }

        function showMessage(text, type) {
            const message = document.getElementById('message');
            message.textContent = text;
            message.className = `message ${type}`;
            message.style.display = 'block';

            setTimeout(() => {
                message.style.display = 'none';
            }, 4000);
        }

        // Initialize
        document.addEventListener('DOMContentLoaded', () => {
            renderNotifications();
            updateStats();
        });
    </script>
</body>
</html>