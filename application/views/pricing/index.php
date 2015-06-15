<?php if (!$this) { exit(header('HTTP/1.0 403 Forbidden')); } ?>

<div class="container">
    <div>

        <h3>Search Price</h3>
        <form action="<?php echo URL_WITH_INDEX_FILE; ?>pricing/index" method="POST" class="form-inline">
            <label>Procedure Id</label>

            <select class="form-control" name="procedureID" id="procedureID"  data-placeholder="Select a procedure" required="">
                <option></option>
                <?php
                    while ($row = sqlsrv_fetch_array($procedures)){
                        echo "<option ".($_POST["procedureID"] ? "selected=\"selected\""  : ""). " value=\"".$row['ProcedureID']."\">" . $row['ProcedureName'] . "</option>";
                    }
                ?>
            </select>

<!--            <input type="text" class="form-control" name="procedureId" value="" required />-->
            <label>Zip Code</label>
            <input type="text"  class="form-control" name="zipCode" value="<?php echo $_POST["zipCode"] ?>"
                   pattern=".{3,}" required title="Enter at least first 3 digits!" />
            <input type="submit" class="btn" name="submit_add_song" value="Submit" />
        </form>
    </div>
    <!-- main content output -->
    <hr/>
    <div>
        <h3>List of prices</h3>
        <table class="table table-hover">
            <thead style="background-color: #ddd; font-weight: bold;">
            <tr>
                <td>Service Code</td>
                <td>Entity Code</td>
                <td>Average Amount</td>
            </tr>
            </thead>
            <tbody>

            <?php

            if( $prices === false ) {

//                foreach ( sqlsrv_errors() as $error )
//                {
//                    echo "SQLSTATE: ".$error['SQLSTATE']."<br/>";
//                    echo "Code: ".$error['code']."<br/>";
//                    echo "Message: ".$error['message']."<br/>";
//                }
                die( print_r( sqlsrv_errors(), true));
            }
                $i=0;
                while ($price = sqlsrv_fetch_array($prices, SQLSRV_FETCH_ASSOC)) {
                    $i=$i+1;
                    ?>
                    <tr>
                        <td><?php if (isset($price['ServiceCode'])) echo htmlspecialchars($price['ServiceCode'], ENT_QUOTES, 'UTF-8'); ?></td>
                        <td><?php if (isset($price['ProviderEntityCode'])) echo htmlspecialchars($price['ProviderEntityCode'], ENT_QUOTES, 'UTF-8'); ?></td>
                        <td><?php if (isset($price['AverageAmt'])) echo htmlspecialchars($price['AverageAmt'], ENT_QUOTES, 'UTF-8'); ?></td>
                    </tr>

            <?php
            }
            if($i==0){  echo '<tr><td colspan="3">No data found!</td></tr>';}
            ?>
            </tbody>
        </table>
    </div>
</div>
