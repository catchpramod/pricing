<?php if (!$this) { exit(header('HTTP/1.0 403 Forbidden')); } ?>
<div class="container">
    <div>
        <h3>Procedure List</h3>
        <table class="table table-hover">
            <thead >
            <tr>
                <td>Procedure ID</td>
                <td>Procedure Name</td>
                <td>Bundle ID</td>
                <td>Bundle Name</td>

            </tr>
            </thead>
            <tbody>

            <?php
            if(count($procedureList)>0){
                foreach($procedureList as $procedure){
                    ?>
                    <tr>
                        <td> <?php echo '<a href="'.URL_WITH_INDEX_FILE.'procedure/service/'. htmlspecialchars($procedure->bundleID, ENT_QUOTES, 'UTF-8').'">'
                        . htmlspecialchars($procedure->procedureID, ENT_QUOTES, 'UTF-8').'</a>'; ?></td>
                        <td><?php  echo htmlspecialchars($procedure->procedureName, ENT_QUOTES, 'UTF-8'); ?></td>
                        <td><?php  echo htmlspecialchars($procedure->bundleID, ENT_QUOTES, 'UTF-8'); ?></td>
                        <td><?php  echo htmlspecialchars($procedure->bundleName, ENT_QUOTES, 'UTF-8'); ?></td>
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
