<?php if (!$this) { exit(header('HTTP/1.0 403 Forbidden')); } ?>
<div class="container">
    <div>
        <h3>Service List</h3>
        <table class="table table-hover">
            <thead >
            <tr>
                <td>BundleID</td>
                <td>ServiceCode</td>
                <td>ServiceType</td>
                <td>ProviderType</td>
            </tr>
            </thead>
            <tbody>

            <?php
            if(count($serviceList)>0){
                foreach($serviceList as $service){
                    ?>
                    <tr>
                        <td><?php  echo htmlspecialchars($service->bundleID, ENT_QUOTES, 'UTF-8'); ?></td>
                        <td><?php  echo htmlspecialchars($service->serviceCode, ENT_QUOTES, 'UTF-8'); ?></td>
                        <td><?php  echo htmlspecialchars($service->serviceType, ENT_QUOTES, 'UTF-8'); ?></td>
                        <td><?php  echo htmlspecialchars($service->providerType, ENT_QUOTES, 'UTF-8'); ?></td>
                    </tr>
                    <?php
                }

            } else{
                echo '<tr><td colspan="4">No data found!</td></tr>' ;
            }

            ?>
            </tbody>
        </table>
    </div>
</div>
