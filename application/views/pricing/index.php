<?php if (!$this) {
    exit(header('HTTP/1.0 403 Forbidden'));
} ?>
<div class="container">
    <div>

        <h3>Search Price</h3>

        <form id="price_search" action="<?php echo URL_WITH_INDEX_FILE; ?>pricing/index" method="POST" class="form-inline">
            <label>Procedure</label>

            <select class="form-control" name="procedureID" id="procedureID" data-placeholder="Select a procedure"
                    required="">
                <option></option>
                <?php
                while ($row = sqlsrv_fetch_array($procedures)) {
                    echo "<option " . ($_POST["procedureID"] == $row['ProcedureID'] ? "selected=\"selected\"" : "") . " value=\"" . $row['ProcedureID'] . "\">" . $row['ProcedureName'] . "</option>";
                }
                ?>
            </select>

            <!--            <input type="text" class="form-control" name="procedureId" value="" required />-->
            <label>Zip Code</label>
            <input type="text" class="form-control" name="zipCode" value="<?php echo($_POST["zipCode"] ?: '53203') ?>"
                   pattern=".{3,}" required title="Enter at least first 3 digits!"/>
            <input type="submit" class="btn" name="submit_add_song" value="Submit"/>
        </form>
    </div>
    <!-- main content output -->
    <hr/>
    <div>
        <div id="loader_wrapper" style="text-align: center; display: none;">
            <div class="throbber-loader">
                Loading…
            </div>
            <link rel="stylesheet" href="http://css-spinners.com/css/spinner/throbber.css" type="text/css">
        </div>

        <div id="price_wrapper">
            <h3>List of prices</h3>
            <table class="table table-hover">
                <thead>
                <tr>
                    <td>Service Code</td>
                    <td>Provider</td>
                    <td>Average Medicare Amount</td>
                    <td>Average Medicare Multiplier</td>
                    <td>Average Amount</td>
                </tr>
                </thead>
                <tbody>

                <?php
                if (count($priceBundles) > 0) {
                    foreach ($bundleList as $bundle) {
                        $bundleTotal = 0;
                        $priceList = $priceBundles[$bundle->id];?>
                        <tr>
                            <td colspan="5" style="font-weight: bold;">
                                <?php echo $bundle->name ?>
                            </td>
                        </tr>
                        <?php
                        foreach ($priceList as $price) {
                            $bundleTotal += $price->averageAmount;
                            ?>

                            <tr>
                                <td><?php if (isset($price->serviceCode)) echo htmlspecialchars($price->serviceCode, ENT_QUOTES, 'UTF-8'); ?></td>
                                <td><?php if (isset($price->providerType)) echo htmlspecialchars(($price->providerType), ENT_QUOTES, 'UTF-8'); ?></td>
                                <td><?php if (isset($price->medicareAvg)) echo '$ ' . htmlspecialchars(number_format($price->medicareAvg, 2), ENT_QUOTES, 'UTF-8'); ?></td>
                                <td><?php if (isset($price->averageAmount) and isset($price->medicareAvg)) echo htmlspecialchars(number_format($price->averageAmount / $price->medicareAvg, 2), ENT_QUOTES, 'UTF-8'); ?></td>
                                <td><?php if (isset($price->averageAmount)) echo '$ ' . htmlspecialchars(number_format($price->averageAmount, 2), ENT_QUOTES, 'UTF-8'); ?></td>
                            </tr>
                        <?php
                        }

                        echo '<tr style="font-weight: bold;">
                             <td colspan="3"></td>
                             <td>' . $bundle->name . ' Total</td>
                             <td>$ ' . number_format($bundleTotal, 2) . '</td>
                          </tr>';
                    }

                } else {
                    echo '<tr><td colspan="5">No data found!</td></tr>';
                }

                //            if( $prices === false ) {
                //                foreach ( sqlsrv_errors() as $error )
                //                {
                //                    echo "SQLSTATE: ".$error['SQLSTATE']." ";
                //                    echo "Code: ".$error['code']." ";
                //                    echo "Message: ".$error['message']." ";
                //                }
                //                die( print_r( sqlsrv_errors(), true));
                //            }
                ?>
                </tbody>
            </table>
        </div>

    </div>
</div>
