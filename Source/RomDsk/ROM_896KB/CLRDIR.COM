͓CLRDIR Version 1.2b May 2024 by Max Scane

$͠:� � ��:� �Aڋ�ҋ2�:� �::� ���::� �-:� �D�y>2����T��>2�2��͓Test option selected. No disk writes will be performed 
$���Y>2�:�����;V�� �":�O �w}�ʋ�b:��q:���Ëͪ:������!0�:��� �"��*�+"�|��"}��"͓Directory cleared. $��  ^#V�"��	 :��w ^#V�^#V#�"��#####^#V#�"��####^#V�"��:��#~2��*�"�!  "�*�#����"�:��:������"������"�:��*���"������"��7?|g}o�͓Drive: $:��A�
>:�
�͓Sectors Per Track: $:���:����͓Directory Size: $:���:����͓Track Offset: $:���:����͓Sectors to write: $:���:����:��͓Sector size code: $:�����*�#"��*�|��}��!  "�*�#"��>� !�w#������́:���L*�MD*��͵DM͋͟��́:���L*�MD͕*�MD*��͵DM͋ͩ�>T�
>:�
*��|���}��*�MD͕> �
>S�
>:�
*��|���}����	� �  �~#��$��
Ó� |���}�1�2͓CP/M 3 Detected
$�͓MP/M Not Currently Supported 
$�  �� �
�� �
���0�:���_� �� �>�
>
�
�: 2�2�2�2�2�2�2��͓Warning - this utility will overwrite the directory sectors of $͓Drive: $:��A�
�͓Type CAPITAL Y to proceed, any key other key to exit. $��Y�͓Usage: CLRDIR <drive> [-D, -Y]
Clear the directory sectors of the specified drive.

Options:
-D  Enable debug output.
-Y  Do not ask for confirmation.
$�  :���ÿ:�����:�����:�����:����� :�����:������ � �! �$ �' �* �0 >	��>
��>��>��>��>��>��2"`i"bk"2� �� �         Invalid drive specified.
$Invalid option specified.
$
Directory NOT cleared.
$Sector sizes > 512 Bytes not supported.
$                   