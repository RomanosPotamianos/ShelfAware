import java.util.Date;

public class Notification {
    private int notificationId;
    private int productId;
    private String message;
    private Date notificationDate;
    private boolean isRead;

    public int getNotificationId() {
        return notificationId;
    }
    public void setNotificationId(int notificationId) {
        this.notificationId = notificationId;
    }
    public int getProductId() {
        return productId;
    }
    public void setProductId(int productId) {
        this.productId = productId;
    }
    public String getMessage() {
        return message;
    }
    public void setMessage(String message) {
        this.message = message;
    }
    public Date getNotificationDate() {
        return notificationDate;
    }
    public void setNotificationDate(Date notificationDate) {
        this.notificationDate = notificationDate;
    }
    public boolean isRead() {
        return isRead;
    }
    public void setRead(boolean isRead) {
        this.isRead = isRead;
    }
}
