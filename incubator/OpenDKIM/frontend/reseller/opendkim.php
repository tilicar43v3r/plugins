<?php
/**
 * i-MSCP - internet Multi Server Control Panel
 * Copyright (C) 2010-2014 by i-MSCP Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 * @category    iMSCP
 * @package     iMSCP_Plugin
 * @subpackage  OpenDKIM
 * @copyright   Sascha Bay <info@space2place.de>
 * @author      Sascha Bay <info@space2place.de>
 * @link        http://www.i-mscp.net i-MSCP Home Site
 * @license     http://www.gnu.org/licenses/gpl-2.0.html GPL v2
 */

/***********************************************************************************************************************
 * Functions
 */

/**
 * Activate OpenDKIM for the given customer
 *
 * @param int $customerId Customer unique identifier
 * @return void
 */
function opendkim_activate($customerId)
{
	$stmt = exec_query(
		'
			SELECT
				domain_id, domain_name, domain_dns
			FROM
				domain
			INNER JOIN
				admin ON(admin_id = domain_admin_id)
			WHERE
				admin_id = ?
			AND
				created_by = ?
			AND
				admin_status = ?
		',
		array($customerId, $_SESSION['user_id'], 'ok')
	);

	if ($stmt->rowCount()) {
		$row = $stmt->fetchRow(PDO::FETCH_ASSOC);
		$db = iMSCP_Database::getInstance();

		try {
			$db->beginTransaction();
			exec_query(
				'
					INSERT INTO opendkim (
						admin_id, domain_id, alias_id, domain_name, customer_dns_previous_status, opendkim_status
					) VALUES (
						?, ?, ?, ?, ?, ?
					)
				',
				array($customerId, $row['domain_id'], '0', $row['domain_name'], $row['domain_dns'], 'toadd')
			);

			$stmt = exec_query(
				'SELECT alias_id, alias_name FROM domain_aliasses WHERE domain_id = ? AND alias_status = ?',
				array($row['domain_id'], 'ok')
			);

			if ($stmt->rowCount()) {
				while ($row2 = $stmt->fetchRow(PDO::FETCH_ASSOC)) {
					exec_query(
						'
							INSERT INTO  opendkim (
								admin_id, domain_id, alias_id, domain_name, customer_dns_previous_status,
								opendkim_status
							) VALUES (
								?, ?, ?, ?, ?, ?
							)
						',
						array($customerId, $row['domain_id'], $row2['alias_id'], $row2['alias_name'], '', 'toadd')
					);
				}
			}

			$db->commit();

			send_request();

			set_page_message(tr('OpenDKIM support scheduled for activation. This can take few seconds...'), 'success');
		} catch (iMSCP_Exception_Database $e) {
			$db->rollBack();
			throw $e;
		}
	} else {
		showBadRequestErrorPage();
	}
}

/**
 * Deactivate OpenDKIM for the given customer
 *
 * @param int $customerId Customer unique identifier
 * @return void
 */
function opendkim_deactivate($customerId)
{
	$stmt = exec_query(
		'SELECT admin_id, admin_name FROM admin WHERE admin_id = ? AND created_by = ? AND admin_status = ?',
		array($customerId, $_SESSION['user_id'], 'ok'));

	if ($stmt->rowCount()) {
		exec_query('UPDATE opendkim SET opendkim_status = ? WHERE admin_id = ?', array('todelete', $customerId));

		send_request();
		set_page_message(tr('OpenDKIM support scheduled for deactivation. This can take few seconds.'), 'success');
	} else {
		showBadRequestErrorPage();
	}
}

/**
 * Generate customer list for which OpenDKIM can be activated
 *
 * @param $tpl iMSCP_pTemplate
 * @return void
 */
function _opendkim_generateCustomerList($tpl)
{
	$stmt = exec_query(
		'
			SELECT
				admin_id, admin_name
			FROM
				admin
			WHERE
				created_by = ?
			AND
				admin_status = ?
			AND
				admin_id NOT IN (SELECT admin_id FROM opendkim)
			ORDER BY
				admin_name ASC
		',
		array($_SESSION['user_id'], 'ok')
	);

	if ($stmt->rowCount()) {
		while ($row = $stmt->fetchRow(PDO::FETCH_ASSOC)) {
			$tpl->assign(
				array(
					'SELECT_VALUE' => $row['admin_id'],
					'SELECT_NAME' => tohtml(decode_idna($row['admin_name'])),
				)
			);

			$tpl->parse('SELECT_ITEM', '.select_item');
		}
	} else {
		$tpl->assign('SELECT_LIST', '');
	}
}

/**
 * Generate page
 *
 * @param iMSCP_pTemplate $tpl
 * @return void
 */
function opendkim_generatePage($tpl)
{
	_opendkim_generateCustomerList($tpl, $_SESSION['user_id']);

	/** @var $cfg iMSCP_Config_Handler_File */
	$cfg = iMSCP_Registry::get('config');

	$rowsPerPage = $cfg['DOMAIN_ROWS_PER_PAGE'];

	if (isset($_GET['psi']) && $_GET['psi'] == 'last') {
		unset($_GET['psi']);
	}

	$startIndex = isset($_GET['psi']) ? (int)$_GET['psi'] : 0;

	$stmt = exec_query(
		'
			SELECT
				COUNT(admin_id) AS cnt
			FROM
				admin
			INNER JOIN
				opendkim USING(admin_id)
			WHERE
				created_by = ?
			AND
				alias_id = ?
		',
		array($_SESSION['user_id'], 0)
	);
	$row = $stmt->fetchRow(PDO::FETCH_ASSOC);
	$rowCount = $row['cnt'];

	if ($rowCount) {
		$stmt = exec_query(
			"
				SELECT
					admin_name, admin_id
				FROM
					admin
				INNER JOIN
					opendkim USING(admin_id)
				WHERE
					created_by = ?
				AND
					alias_id = ?
				ORDER BY
					admin_id ASC
				LIMIT
					$startIndex, $rowsPerPage
			",
			array($_SESSION['user_id'], 0)
		);

		while ($row = $stmt->fetchRow()) {
			$stmt2 = exec_query(
				'
					SELECT
						opendkim_id, domain_name, opendkim_status, domain_dns, domain_text
					FROM
						opendkim
					LEFT JOIN
						domain_dns USING(domain_id, alias_id)
					WHERE
						admin_id = ?
					AND
						(owned_by = ? OR owned_by IS NULL)
					ORDER BY
						domain_id ASC, alias_id ASC
				',
				array($row['admin_id'], 'OpenDKIM_Plugin')
			);

			if ($stmt2->rowCount()) {
				while ($row2 = $stmt2->fetchRow()) {
					if ($row2['opendkim_status'] == 'ok') {
						$statusIcon = 'ok';
					} elseif ($row2['opendkim_status'] == 'disabled') {
						$statusIcon = 'disabled';
					} elseif (in_array($row2['opendkim_status'], array(
						'toadd', 'tochange', 'todelete', 'torestore', 'tochange', 'toenable', 'todisable',
						'todelete'))
					) {
						$statusIcon = 'reload';
					} else {
						$statusIcon = 'error';
					}

					$tpl->assign(
						array(
							'KEY_STATUS' => translate_dmn_status($row2['opendkim_status']),
							'STATUS_ICON' => $statusIcon,
							'DOMAIN_NAME' => tohtml(decode_idna($row2['domain_name'])),
							'DOMAIN_KEY' => ($row2['domain_text'])
								? tohtml($row2['domain_text']) : tr('Generation in progress...'),
							'DNS_NAME' => ($row2['domain_dns'])
								? tohtml(decode_idna($row2['domain_dns'])) . '.' .
									tohtml(decode_idna($row2['domain_name'])) . '.'
								: tr('n/a'),
							'OPENDKIM_ID' => tohtml($row2['opendkim_id']),

						)
					);

					$tpl->parse('KEY_ITEM', '.key_item');
				}
			}

			$tpl->assign(
				array(
					'TR_CUSTOMER' => tr('OpenDKIM entries for customer: %s', decode_idna($row['admin_name'])),
					'TR_DEACTIVATE' => tr('Deactivate OpenDKIM'),
					'CUSTOMER_ID' => tohtml($row['admin_id'])
				)
			);

			$tpl->parse('CUSTOMER_ITEM', '.customer_item');
			$tpl->assign('KEY_ITEM', '');
		}

		$prevSi = $startIndex - $rowsPerPage;

		if ($startIndex == 0) {
			$tpl->assign('SCROLL_PREV', '');
		} else {
			$tpl->assign(
				array(
					'SCROLL_PREV_GRAY' => '',
					'PREV_PSI' => $prevSi
				)
			);
		}

		$nextSi = $startIndex + $rowsPerPage;

		if ($nextSi + 1 > $rowCount) {
			$tpl->assign('SCROLL_NEXT', '');
		} else {
			$tpl->assign(
				array(
					'SCROLL_NEXT_GRAY' => '',
					'NEXT_PSI' => $nextSi
				)
			);
		}
	} else {
		$tpl->assign('CUSTOMER_LIST', '');
		set_page_message(tr('No customer with OpenDKIM support has been found.'), 'info');
	}
}

/***********************************************************************************************************************
 * Main
 */

iMSCP_Events_Aggregator::getInstance()->dispatch(iMSCP_Events::onResellerScriptStart);

check_login('reseller');

/** @var $cfg iMSCP_Config_Handler_File */
$cfg = iMSCP_Registry::get('config');

if (resellerHasCustomers()) {
	if (isset($_REQUEST['action'])) {
		$action = clean_input($_REQUEST['action']);

		if (isset($_REQUEST['admin_id']) && $_REQUEST['admin_id'] != '') {
			$customerId = clean_input($_REQUEST['admin_id']);

			switch ($action) {
				case 'activate':
					opendkim_activate($customerId);
					break;
				case 'deactivate';
					opendkim_deactivate($customerId);
					break;
				default:
					showBadRequestErrorPage();
			}

			redirectTo('opendkim.php');
		} else {
			showBadRequestErrorPage();
		}
	}

	$tpl = new iMSCP_pTemplate();
	$tpl->define_dynamic(
		array(
			'layout' => 'shared/layouts/ui.tpl',
			'page' => '../../plugins/OpenDKIM/frontend/reseller/opendkim.tpl',
			'page_message' => 'layout',
			'select_list' => 'page',
			'select_item' => 'select_list',
			'customer_list' => 'page',
			'customer_item' => 'customer_list',
			'key_item' => 'customer_item',
			'scroll_prev_gray' => 'customer_list',
			'scroll_prev' => 'customer_list',
			'scroll_next_gray', 'customer_list',
			'scroll_next' => 'customer_list'
		)
	);

	$tpl->assign(
		array(
			'TR_PAGE_TITLE' => tr('Customers / OpenDKIM'),
			'THEME_CHARSET' => tr('encoding'),
			'ISP_LOGO' => layout_getUserLogo(),
			'TR_SELECT_NAME' => tr('Select a customer'),
			'TR_ACTIVATE_ACTION' => tr('Activate OpenDKIM for this customer'),
			'TR_DOMAIN_NAME' => tr('Domain Name'),
			'TR_DOMAIN_KEY' => tr('OpenDKIM domain key'),
			'TR_STATUS' => tr('Status'),
			'TR_DNS_NAME' => tr('Name'),
			'DEACTIVATE_DOMAIN_ALERT' => tojs(tr('Are you sure you want to deactivate OpenDKIM for this customer?', true)),
			'TR_PREVIOUS' => tr('Previous'),
			'TR_NEXT' => tr('Next')
		)
	);

	generateNavigation($tpl);
	opendkim_generatePage($tpl);
	generatePageMessage($tpl);

	$tpl->parse('LAYOUT_CONTENT', 'page');

	iMSCP_Events_Aggregator::getInstance()->dispatch(iMSCP_Events::onResellerScriptEnd, array('templateEngine' => $tpl));

	$tpl->prnt();
} else {
	showBadRequestErrorPage();
}
