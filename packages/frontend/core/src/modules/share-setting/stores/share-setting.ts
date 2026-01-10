import type { WorkspaceServerService } from '@affine/core/modules/cloud';
import {
  getWorkspaceConfigQuery,
  setEnableAiMutation,
  setEnableSharingMutation,
  setEnableUrlPreviewMutation,
} from '@affine/graphql';
import { Store } from '@toeverything/infra';

export class WorkspaceShareSettingStore extends Store {
  constructor(private readonly workspaceServerService: WorkspaceServerService) {
    super();
  }

  async fetchWorkspaceConfig(workspaceId: string, signal?: AbortSignal) {
    if (!this.workspaceServerService.server) {
      throw new Error('No Server');
    }
    const data = await (this.workspaceServerService.server as any).gql({
      query: getWorkspaceConfigQuery,
      variables: {
        id: workspaceId,
      },
      context: {
        signal,
      },
    });
    return data.workspace;
  }

  async updateWorkspaceEnableAi(
    workspaceId: string,
    enableAi: boolean,
    signal?: AbortSignal
  ) {
    if (!this.workspaceServerService.server) {
      throw new Error('No Server');
    }
    await (this.workspaceServerService.server as any).gql({
      query: setEnableAiMutation,
      variables: {
        id: workspaceId,
        enableAi,
      },
      context: {
        signal,
      },
    });
  }

  async updateWorkspaceEnableSharing(
    workspaceId: string,
    enableSharing: boolean,
    signal?: AbortSignal
  ) {
    if (!this.workspaceServerService.server) {
      throw new Error('No Server');
    }
    await this.workspaceServerService.server.gql({
      query: setEnableSharingMutation,
      variables: {
        id: workspaceId,
        enableSharing,
      },
      context: {
        signal,
      },
    });
  }

  async updateWorkspaceEnableUrlPreview(
    workspaceId: string,
    enableUrlPreview: boolean,
    signal?: AbortSignal
  ) {
    if (!this.workspaceServerService.server) {
      throw new Error('No Server');
    }
    await this.workspaceServerService.server.gql({
      query: setEnableUrlPreviewMutation,
      variables: {
        id: workspaceId,
        enableUrlPreview,
      },
      context: {
        signal,
      },
    });
  }

  async fetchWorkspaceDocPolicy(
    workspaceId: string,
    signal?: AbortSignal
  ): Promise<boolean> {
    if (!this.workspaceServerService.server) {
      throw new Error('No Server');
    }
    const data = await this.workspaceServerService.server.gql({
      query: `query GetWorkspaceDocPolicy($id: ID!) {
        workspace(id: $id) {
          id
          workspaceMembersNoAccessByDefault
        }
      }`,
      variables: { id: workspaceId },
      context: { signal },
    });
    const ws: any = (data as any).workspace;
    return Boolean(ws?.workspaceMembersNoAccessByDefault);
  }

  async updateWorkspaceDocDefaultRole(
    workspaceId: string,
    role: 'None' | 'Manager',
    signal?: AbortSignal
  ) {
    if (!this.workspaceServerService.server) {
      throw new Error('No Server');
    }
    await this.workspaceServerService.server.gql({
      query: `mutation SetWorkspaceDocDefaultRole($workspaceId: ID!, $role: DocRole!) {
        setWorkspaceDocDefaultRole(workspaceId: $workspaceId, role: $role)
      }`,
      variables: { workspaceId, role },
      context: { signal },
    });
  }
}
