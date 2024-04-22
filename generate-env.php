<?php
// Define the default .env content
$defaultEnvContent = <<<ENV
IP=127.0.0.1
# Replace 83 and the mysite.local name
PORT=83
SSL_PORT=4483
MY_ADMIN_PORT=8083
MY_DB_PORT=33083
DB_ROOT_PASSWORD=password83
DB_NAME=wp_mysslsite83
MY_SITE_NAME=mysite.local
MY_USER=adk
CONTAINER_UID=1000
CONTAINER_GID=1000
#FULL_URL=https://mysite.local:8443
ENV;

$updatedEnv = $defaultEnvContent; // Initialize with default content

// Check if the form was submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Get the port number and site name from the form, validate for empty submissions
    $port = !empty($_POST['port']) ? $_POST['port'] : '83'; // Default if empty or invalid
    $siteName = !empty($_POST['siteName']) ? $_POST['siteName'] : 'mysite.local'; // Default if empty

    // Replace the port number and site name in the .env content
    $updatedEnv = str_replace(['83', 'mysite.local'], [$port, $siteName], $defaultEnvContent);

    // Save the updated content to a new .env file
    file_put_contents('.env', $updatedEnv);

    $successMessage = "<div class=\"notification is-success\">
                           <button class=\"delete\"></button>
                           .env file has been updated successfully.
                       </div>";
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Generate .env File</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.3/css/bulma.min.css">
</head>
<body>
<div class="container">
    <div class="columns">
        <div class="column is-half" id="left">
            <h1 class="title is-4">Current .env Configuration</h1>
            <pre><?php echo htmlentities($updatedEnv); ?></pre>
        </div>
        <div class="column is-half">
            <h1 class="title is-4">Update .env Configuration</h1>
            <div class="form form-group">
                <form method="post" action="">
                    <div class="field">
                        <label class="label" for="port">Port Adjustment:</label>
                        <div class="control">
                            <input class="input" type="number" id="port" name="port" value="<?php echo $port ?? '83'; ?>" required>
                        </div>
                    </div>
                    <div class="field">
                        <label class="label" for="siteName">Site Name:</label>
                        <div class="control">
                            <input class="input" type="text" id="siteName" name="siteName" value="<?php echo $siteName ?? 'mysite.local'; ?>" placeholder="Enter site name" required>
                        </div>
                    </div>
                    <div class="control">
                        <input class="button is-primary" type="submit" value="Submit">
                    </div>
                </form>
            </div>
        </div>
    </div>
    <?php if (isset($successMessage)) echo $successMessage; ?>
</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        (document.querySelectorAll('.delete') || []).forEach(($delete) => {
            const $notification = $delete.parentNode;

            $delete.addEventListener('click', () => {
                $notification.parentNode.removeChild($notification);
            });
        });
    });
</script>

</body>
</html>
